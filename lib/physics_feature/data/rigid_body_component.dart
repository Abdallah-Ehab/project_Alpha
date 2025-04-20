import 'dart:ui';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class RigidBodyComponent extends Component {
  Offset velocity = Offset.zero;
  double mass = 1.0;
  bool useGravity = true;
  double gravity = 0.1;
  bool isStatic = false; 
  bool isGrounded = false; 

  RigidBodyComponent({this.isStatic = false});

  void applyForce({double fx = 0.0, double fy = 0.0}) {
    if (isStatic) return;
    velocity += Offset(fx, fy);
  }

  void applyForceX(double fx) => applyForce(fx: fx);

  void applyForceY(double fy) => applyForce(fy: fy);

  void setVelocity(double vx, double vy) {
    if (isStatic) return;
    velocity = Offset(vx, vy);
    
    if (vy < 0) {
      isGrounded = false;
      useGravity = true;
    }
    notifyListeners();
  }

  void setGravity(double g) {
    gravity = g;
    notifyListeners();
  }

  void landOnGround() {
    if (isStatic) return;
    isGrounded = true;
    useGravity = false;
    velocity = Offset(velocity.dx, 0);
    notifyListeners();
  }

  void leaveGround() {
    if (isStatic) return;
    isGrounded = false;
    useGravity = true;
    notifyListeners();
  }

  @override
  void update(
    Duration dt, {
    required Entity activeEntity,
  }) {
    if (isStatic) return;

    final double seconds = dt.inMilliseconds / 1000.0;

    if (useGravity) {
      velocity += Offset(0, gravity * seconds);
    }

    final dx = velocity.dx * seconds;
    final dy = velocity.dy * seconds;

    activeEntity.move(x: dx, y: dy);
  }
}