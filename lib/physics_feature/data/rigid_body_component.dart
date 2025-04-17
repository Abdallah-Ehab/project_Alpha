import 'dart:ui';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class RigidBody extends Component {
  Offset velocity = Offset.zero;
  double mass = 1.0; // Optional, for future force = mass * acceleration stuff
  bool useGravity = true;
  double gravity = 9.8;

  /// Apply force in both x and y axes
  void applyForce({double fx = 0.0, double fy = 0.0}) {
    // Basic F = ma => a = F / m
    // Here we just accumulate velocity for simplicity
    velocity += Offset(fx, fy);
  }

  /// Apply force on X axis only
  void applyForceX(double fx) => applyForce(fx: fx);

  /// Apply force on Y axis only
  void applyForceY(double fy) => applyForce(fy: fy);

  /// Optional: instantly set velocity (e.g., teleport or dash)
  void setVelocity(double vx, double vy) {
    velocity = Offset(vx, vy);
  }

  @override
  void update(
    Duration dt, {
    required Entity activeEntity,
    required EntityManager entityManager,
  }) {
    final double seconds = dt.inMilliseconds / 1000.0;

    if (useGravity) {
      // Apply gravity (force over time)
      velocity += Offset(0, gravity * seconds);
    }

    // Update entity position
    final dx = velocity.dx * seconds;
    final dy = velocity.dy * seconds;

    activeEntity.move(x: dx, y: dy);
  }
}
