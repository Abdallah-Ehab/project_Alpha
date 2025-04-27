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
  });

  @override
  void update(
    Duration dt, {
    required Entity activeEntity,
    
  }) {
    final List<Entity> otherEntities = EntityManager()
        .entities[EntityType.actors]!.values
        .where(
          (e) =>
              e != activeEntity && e.getComponent<ColliderComponent>() != null,
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

        // if atleast one entity is static
        if (activeRigidBody == null || activeRigidBody.isStatic) continue;
        if (otherRigidBody != null && otherRigidBody.isStatic) {
          // Active entity is non-static, other is static
          if (overlapX < overlapY) {
            // Resolve X collision
            final dx = (a.center.dx < b.center.dx) ? -overlapX : overlapX;
            activeEntity.move(x: dx);
            activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
          } else {
            // Resolve Y collision
            final dy = (a.center.dy < b.center.dy) ? -overlapY : overlapY;
            activeEntity.move(y: dy);
            if (dy < 0) {
              // Active entity landed on top of static entity
              activeRigidBody.landOnGround();
            } else {
              // Active entity hit something from below or side
              activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
            }
          }
        } else if (otherRigidBody != null && !otherRigidBody.isStatic) {
          // Both entities are non-static; split the resolution
          final halfOverlapX = overlapX / 2;
          final halfOverlapY = overlapY / 2;
          if (overlapX < overlapY) {
            final dx = (a.center.dx < b.center.dx) ? -halfOverlapX : halfOverlapX;
            activeEntity.move(x: dx);
            other.move(x: -dx);
            activeRigidBody.setVelocity(0, activeRigidBody.velocity.dy);
            otherRigidBody.setVelocity(0, otherRigidBody.velocity.dy);
          } else {
            final dy = (a.center.dy < b.center.dy) ? -halfOverlapY : halfOverlapY;
            activeEntity.move(y: dy);
            other.move(y: -dy);
            if (dy < 0) {
              activeRigidBody.landOnGround();
            } else {
              activeRigidBody.setVelocity(activeRigidBody.velocity.dx, 0);
            }
            if (dy > 0) {
              otherRigidBody.landOnGround();
            } else {
              otherRigidBody.setVelocity(otherRigidBody.velocity.dx, 0);
            }
          }
        }
      } else {
        // No collision; if active entity was grounded, check if it should leave ground
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
  
  @override
  void reset() {
   return;
  }
}