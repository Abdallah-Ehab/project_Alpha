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
    final List<Entity> otherEntities = EntityManager()
        .entities[EntityType.actors]!
        .values
        .where(
          (e) =>
              e != activeEntity &&
              e.getComponent<ColliderComponent>() != null,
        )
        .toList();

    final activeRigidBody = activeEntity.getComponent<RigidBodyComponent>();

    for (var other in otherEntities) {
      final ColliderComponent? otherCollider =
          other.getComponent<ColliderComponent>();
      final RigidBodyComponent? otherRigidBody =
          other.getComponent<RigidBodyComponent>();

      if (otherCollider == null ||
          activeEntity.layerNumber != other.layerNumber) {
        continue;
      }

      final Rect a = getRect(activeEntity);
      final Rect b = otherCollider.getRect(other);

      final bool xOverlap = a.left < b.right && a.right > b.left;
      final bool yOverlap = a.top < b.bottom && a.bottom > b.top;

      if (xOverlap && yOverlap) {
        final double overlapX =
            (a.center.dx < b.center.dx) ? a.right - b.left : b.right - a.left;
        final double overlapY =
            (a.center.dy < b.center.dy) ? a.bottom - b.top : b.bottom - a.top;

        // If active is static, skip resolving
        if (activeRigidBody == null || activeRigidBody.isStatic) continue;

        // Handle collision with static other
        if (otherRigidBody != null && otherRigidBody.isStatic) {
          if (overlapX < overlapY) {
            final dx = (a.center.dx < b.center.dx) ? -overlapX : overlapX;
            activeEntity.move(x: dx);
            activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
          } else {
            final dy = (a.center.dy < b.center.dy) ? -overlapY : overlapY;
            activeEntity.move(y: dy);
            if (dy < 0) {
              activeRigidBody.landOnGround();
            } else {
              activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
            }
          }
        }

        // Handle dynamic vs dynamic with mass
        else if (otherRigidBody != null && !otherRigidBody.isStatic) {
          final bool activeIsHeavier =
              activeRigidBody.mass > otherRigidBody.mass;
          final bool otherIsHeavier =
              otherRigidBody.mass > activeRigidBody.mass;

          final double dx = (a.center.dx < b.center.dx) ? -overlapX : overlapX;
          final double dy = (a.center.dy < b.center.dy) ? -overlapY : overlapY;

          if (activeIsHeavier) {
            if (overlapX < overlapY) {
              other.move(x: -dx);
              otherRigidBody.setVelocity(
                  dx.sign * activeRigidBody.velocity.dx.abs(),
                  otherRigidBody.velocity.dy);
              activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
            } else {
              other.move(y: -dy);
              otherRigidBody.setVelocity(
                  otherRigidBody.velocity.dx,
                  dy.sign * activeRigidBody.velocity.dy.abs());
              if (dy > 0) otherRigidBody.landOnGround();
              activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
            }
          } else if (otherIsHeavier) {
            if (overlapX < overlapY) {
              activeEntity.move(x: dx);
              activeRigidBody.setVelocity(
                  dx.sign * otherRigidBody.velocity.dx.abs(),
                  activeRigidBody.velocity.dy);
              otherRigidBody.setVelocity(0, otherRigidBody.velocity.dy);
            } else {
              activeEntity.move(y: dy);
              activeRigidBody.setVelocity(
                  activeRigidBody.velocity.dx,
                  dy.sign * otherRigidBody.velocity.dy.abs());
              if (dy < 0) activeRigidBody.landOnGround();
              otherRigidBody.setVelocity(otherRigidBody.velocity.dx, 0);
            }
          } else {
            // Equal mass: split resolution
            final halfOverlapX = overlapX / 2;
            final halfOverlapY = overlapY / 2;

            if (overlapX < overlapY) {
              final dxHalf =
                  (a.center.dx < b.center.dx) ? -halfOverlapX : halfOverlapX;
              activeEntity.move(x: dxHalf);
              other.move(x: -dxHalf);
              activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
              otherRigidBody.setVelocity(0, otherRigidBody.velocity.dy);
            } else {
              final dyHalf =
                  (a.center.dy < b.center.dy) ? -halfOverlapY : halfOverlapY;
              activeEntity.move(y: dyHalf);
              other.move(y: -dyHalf);
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
          }
        }
      } else {
        // Not overlapping, but check if still grounded
        if (activeRigidBody != null && activeRigidBody.isGrounded) {
          final groundRect = Rect.fromLTWH(
            a.left,
            a.bottom,
            a.width,
            1,
          );
          if (!groundRect.overlaps(b)) {
            activeRigidBody.leaveGround();
          }
        }
      }
    }
  }

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

  void setX(double x){
    position = Offset(x,position.dy);
    notifyListeners();
  }
  void setY(double y){
    position = Offset(position.dx,y);
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
