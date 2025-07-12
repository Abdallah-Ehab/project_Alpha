import 'dart:ui';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';

class ColliderComponent extends Component {
  Offset position;
  double width;
  double height;

  ColliderComponent({
    this.position = Offset.zero,
    this.width = 50,
    this.height = 50,
    super.isActive,
  });

  @override
  void update(
    Duration dt, {
    required Entity activeEntity,
  }) {
    final List<Entity> otherEntities = _getCollidableEntities(activeEntity);
    final activeRigidBody = activeEntity.getComponent<RigidBodyComponent>();

    for (var other in otherEntities) {
      final ColliderComponent? otherCollider =
          other.getComponent<ColliderComponent>();
      final RigidBodyComponent? otherRigidBody =
          other.getComponent<RigidBodyComponent>();

      if (!_shouldCheckCollision(activeEntity, other, otherCollider)) {
        continue;
      }

      final Rect activeRect = getRect(activeEntity);
      final Rect otherRect = otherCollider!.getRect(other);

      if (_areRectsOverlapping(activeRect, otherRect)) {
        _handleCollision(activeEntity, other, activeRect, otherRect,
            activeRigidBody, otherRigidBody);
      } else {
        _handleGroundCheck(
            activeEntity, activeRect, otherRect, activeRigidBody);
      }
    }
  }

  List<Entity> _getCollidableEntities(Entity activeEntity) {
    return EntityManager()
        .entities[EntityType.actors]!
        .values
        .where(
          (e) =>
              e != activeEntity && e.getComponent<ColliderComponent>() != null,
        )
        .toList();
  }

  bool _shouldCheckCollision(
      Entity activeEntity, Entity other, ColliderComponent? otherCollider) {
    return otherCollider != null &&
        activeEntity.layerNumber == other.layerNumber;
  }

  bool _areRectsOverlapping(Rect a, Rect b) {
    final bool xOverlap = a.left < b.right && a.right > b.left;
    final bool yOverlap = a.top < b.bottom && a.bottom > b.top;
    return xOverlap && yOverlap;
  }

  void _handleCollision(
    Entity activeEntity,
    Entity other,
    Rect activeRect,
    Rect otherRect,
    RigidBodyComponent? activeRigidBody,
    RigidBodyComponent? otherRigidBody,
  ) {
    final CollisionOverlap overlap = _calculateOverlap(activeRect, otherRect);

    // Skip if active entity is static
    if (activeRigidBody == null || activeRigidBody.isStatic) return;

    if (otherRigidBody != null && otherRigidBody.isStatic) {
      _handleStaticCollision(activeEntity, activeRigidBody, overlap);
    } else if (otherRigidBody != null && !otherRigidBody.isStatic) {
      _handleDynamicCollision(
          activeEntity, other, activeRigidBody, otherRigidBody, overlap);
    }
  }

  CollisionOverlap _calculateOverlap(Rect a, Rect b) {
    final double overlapX =
        (a.center.dx < b.center.dx) ? a.right - b.left : b.right - a.left;
    final double overlapY =
        (a.center.dy < b.center.dy) ? a.bottom - b.top : b.bottom - a.top;
    final double dx = (a.center.dx < b.center.dx) ? -overlapX : overlapX;
    final double dy = (a.center.dy < b.center.dy) ? -overlapY : overlapY;

    return CollisionOverlap(
      overlapX: overlapX,
      overlapY: overlapY,
      dx: dx,
      dy: dy,
    );
  }

  void _handleStaticCollision(
    Entity activeEntity,
    RigidBodyComponent activeRigidBody,
    CollisionOverlap overlap,
  ) {
    if (overlap.overlapX < overlap.overlapY) {
      // Horizontal collision
      activeEntity.move(x: overlap.dx);
      activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
    } else {
      // Vertical collision
      activeEntity.move(y: overlap.dy);
      if (overlap.dy < 0) {
        activeRigidBody.landOnGround();
      } else {
        activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
      }
    }
  }

  void _handleDynamicCollision(
    Entity activeEntity,
    Entity other,
    RigidBodyComponent activeRigidBody,
    RigidBodyComponent otherRigidBody,
    CollisionOverlap overlap,
  ) {
    final bool activeIsHeavier = activeRigidBody.mass > otherRigidBody.mass;
    final bool otherIsHeavier = otherRigidBody.mass > activeRigidBody.mass;

    if (activeIsHeavier && !activeRigidBody.isStatic) {
      _handleHeavierActiveCollision(
          activeEntity, other, activeRigidBody, otherRigidBody, overlap);
    } else if (otherIsHeavier && !otherRigidBody.isStatic) {
      _handleHeavierOtherCollision(
          activeEntity, other, activeRigidBody, otherRigidBody, overlap);
    } else {
      _handleEqualMassCollision(
          activeEntity, other, activeRigidBody, otherRigidBody, overlap);
    }
  }

  void _handleHeavierActiveCollision(
    Entity activeEntity,
    Entity other,
    RigidBodyComponent activeRigidBody,
    RigidBodyComponent otherRigidBody,
    CollisionOverlap overlap,
  ) {
    if (overlap.overlapX < overlap.overlapY) {
      // Horizontal collision
      other.move(x: -overlap.dx);
      otherRigidBody.setVelocity(
          overlap.dx.sign * activeRigidBody.velocity.dx.abs(),
          otherRigidBody.velocity.dy);
      activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
    } else {
      // Vertical collision
      other.move(y: -overlap.dy);
      otherRigidBody.setVelocity(otherRigidBody.velocity.dx,
          overlap.dy.sign * activeRigidBody.velocity.dy.abs());
      if (overlap.dy > 0) otherRigidBody.landOnGround();
      activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
    }
  }

  void _handleHeavierOtherCollision(
    Entity activeEntity,
    Entity other,
    RigidBodyComponent activeRigidBody,
    RigidBodyComponent otherRigidBody,
    CollisionOverlap overlap,
  ) {
    if (overlap.overlapX < overlap.overlapY) {
      // Horizontal collision
      activeEntity.move(x: overlap.dx);
      activeRigidBody.setVelocity(
          overlap.dx.sign * otherRigidBody.velocity.dx.abs(),
          activeRigidBody.velocity.dy);
      otherRigidBody.setVelocity(0, otherRigidBody.velocity.dy);
    } else {
      // Vertical collision
      activeEntity.move(y: overlap.dy);
      activeRigidBody.setVelocity(activeRigidBody.velocity.dx,
          overlap.dy.sign * otherRigidBody.velocity.dy.abs());
      if (overlap.dy < 0) activeRigidBody.landOnGround();
      otherRigidBody.setVelocity(otherRigidBody.velocity.dx, 0);
    }
  }

  void _handleEqualMassCollision(
    Entity activeEntity,
    Entity other,
    RigidBodyComponent activeRigidBody,
    RigidBodyComponent otherRigidBody,
    CollisionOverlap overlap,
  ) {
    final double halfOverlapX = overlap.overlapX / 2;
    final double halfOverlapY = overlap.overlapY / 2;

    if (overlap.overlapX < overlap.overlapY) {
      // Horizontal collision
      final dxHalf = (overlap.dx < 0) ? -halfOverlapX : halfOverlapX;
      activeEntity.move(x: dxHalf);
      other.move(x: -dxHalf);
      activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
      otherRigidBody.setVelocity(0, otherRigidBody.velocity.dy);
    } else {
      // Vertical collision
      final dyHalf = (overlap.dy < 0) ? -halfOverlapY : halfOverlapY;
      activeEntity.move(y: dyHalf);
      other.move(y: -dyHalf);

      _handleVerticalEqualMassCollision(
          activeRigidBody, otherRigidBody, dyHalf);
    }
  }

  void _handleVerticalEqualMassCollision(
    RigidBodyComponent activeRigidBody,
    RigidBodyComponent otherRigidBody,
    double dyHalf,
  ) {
    if (dyHalf < 0) {
      activeRigidBody.landOnGround();
    } else {
      activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
    }

    if (dyHalf > 0) {
      otherRigidBody.landOnGround();
    } else {
      otherRigidBody.setVelocity(otherRigidBody.velocity.dx, 0);
    }
  }

  void _handleGroundCheck(
    Entity activeEntity,
    Rect activeRect,
    Rect otherRect,
    RigidBodyComponent? activeRigidBody,
  ) {
    if (activeRigidBody != null && activeRigidBody.isGrounded) {
      final groundRect = Rect.fromLTWH(
        activeRect.left,
        activeRect.bottom,
        activeRect.width,
        1,
      );
      if (!groundRect.overlaps(otherRect)) {
        activeRigidBody.leaveGround();
      }
    }
  }

// Helper class to encapsulate collision overlap data

  Rect getRect(Entity entity) {
    final pos = entity.position;
    return Rect.fromLTWH(pos.dx, pos.dy, width, height);
  }

  void setWidth(double value) {
    width = value;
    notifyListeners();
  }

  void setHeight(double value) {
    height = value;
    notifyListeners();
  }

  void setPosition(Offset value) {
    position = value;
    notifyListeners();
  }

  void setX(double x) {
    position = Offset(x, position.dy);
    notifyListeners();
  }

  void setY(double y) {
    position = Offset(position.dx, y);
    notifyListeners();
  }

  void move({double? x, double? y}) {
    position += Offset(x ?? 0, y ?? 0);
    notifyListeners();
  }

  @override
  void reset() {
    return;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'collider_component',
      'isActive': isActive,
      'position': {'dx': position.dx, 'dy': position.dy},
      'width': width,
      'height': height,
    };
  }

  static ColliderComponent fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>;
    return ColliderComponent(
      isActive: json['isActive'] as bool? ?? true,
      position: Offset(
        (pos['dx'] as num).toDouble(),
        (pos['dy'] as num).toDouble(),
      ),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  @override
  ColliderComponent copy() {
    return ColliderComponent(
      position: position,
      width: width,
      height: height,
      isActive: isActive,
    );
  }
}

class CollisionOverlap {
  final double overlapX;
  final double overlapY;
  final double dx;
  final double dy;

  CollisionOverlap({
    required this.overlapX,
    required this.overlapY,
    required this.dx,
    required this.dy,
  });
}
