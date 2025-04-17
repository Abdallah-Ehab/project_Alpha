import 'dart:ui';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class ColliderComponent extends Component {
  Offset position = Offset.zero;
  double width = 1.0;
  double height = 1.0;

  @override
  void update(
    Duration dt, {
    required Entity activeEntity,
    required EntityManager entityManager,
  }) {
    final List<Entity> otherEntities = entityManager.entities.values.where(
      (e) =>
          e != activeEntity &&
          e.getComponent<ColliderComponent>() != null,
    ).toList();

    for (var other in otherEntities) {
      final ColliderComponent? otherCollider = other.getComponent<ColliderComponent>();
      if (otherCollider == null || activeEntity.layerNumber != other.layerNumber) continue;

      final Rect a = getRect(activeEntity);
      final Rect b = otherCollider.getRect(other);

      final bool xOverlap = a.left < b.right && a.right > b.left;
      final bool yOverlap = a.top < b.bottom && a.bottom > b.top;

      if (xOverlap && yOverlap) {
        
        final double overlapX = (a.center.dx < b.center.dx)
            ? a.right - b.left
            : b.right - a.left;
        final double overlapY = (a.center.dy < b.center.dy)
            ? a.bottom - b.top
            : b.bottom - a.top;

        if (overlapX < overlapY) {
          final dx = (a.center.dx < b.center.dx) ? -overlapX : overlapX;
          activeEntity.move(x: dx);
        } else {
          final dy = (a.center.dy < b.center.dy) ? -overlapY : overlapY;
          activeEntity.move(y: dy);
        }

      }
    }
  }

  /// Gets the collision box as a Rect
  Rect getRect(Entity entity) {
    final pos = entity.position;
    return Rect.fromLTWH(pos.dx, pos.dy, width, height);
  }
}
