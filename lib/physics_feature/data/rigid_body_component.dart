import 'dart:developer';
import 'dart:ui';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';


class RigidBodyComponent extends Component {
  Offset velocity;
  double mass;
  bool useGravity;
  double gravity;
  bool isStatic;
  bool isGrounded;
  double fallProgress = 0.0;
  final double gravityAccelerationRate = 0.5; // tunable
  final double maxFallSpeed = 20.0;           // optional safety cap

  RigidBodyComponent({
    this.velocity = Offset.zero,
    this.mass = 1.0,
    this.useGravity = true,
    this.gravity = 0.2, // Base gravity value
    this.isStatic = false,
    this.isGrounded = false,
    super.isActive,
  });


  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rigidbody',
      'isActive': isActive,
      'velocity': {'dx': velocity.dx, 'dy': velocity.dy},
      'mass': mass,
      'useGravity': useGravity,
      'gravity': gravity,
      'isStatic': isStatic,
      'isGrounded': isGrounded,
      'fallProgress': fallProgress,
    };
  }

  static RigidBodyComponent fromJson(Map<String, dynamic> json) {
    final vel = json['velocity'] as Map<String, dynamic>;
    return RigidBodyComponent(
      isActive: json['isActive'] as bool? ?? true,
      velocity: Offset(
        (vel['dx'] as num).toDouble(),
        (vel['dy'] as num).toDouble(),
      ),
      mass: (json['mass'] as num).toDouble(),
      useGravity: json['useGravity'] as bool? ?? true,
      gravity: (json['gravity'] as num).toDouble(),
      isStatic: json['isStatic'] as bool? ?? false,
      isGrounded: json['isGrounded'] as bool? ?? false,
    )..fallProgress = (json['fallProgress'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  RigidBodyComponent copy() {
    return RigidBodyComponent(
      velocity: velocity,
      mass: mass,
      useGravity: useGravity,
      gravity: gravity,
      isStatic: isStatic,
      isGrounded: isGrounded,
      isActive: isActive,
    )..fallProgress = fallProgress;
  }

  @override
  void reset() {
    velocity = Offset.zero;
    gravity = 0.2;
    isGrounded = false;
    useGravity = true;
    notifyListeners();
  }


  void applyForce({
    double fx = 0.0,
    double fy = 0.0,
    double resistance = 0.98, // Air resistance factor (0 to 1)
    double friction = 0.95,   // Ground friction factor (0 to 1)
  }) {
    if (isStatic) return;
    
    // Apply force as acceleration (force / mass)
    velocity += Offset(fx / mass, fy / mass);

    // Apply resistance (air drag) if not grounded
    final entity = EntityManager().activeEntity;
    if(entity == null) return;
    checkIfGrounded(entity);

    if (!isGrounded) {
      velocity = Offset(
        velocity.dx * resistance,
        velocity.dy * resistance,
      );
    }

    // Apply friction if grounded (only to horizontal velocity)
    if (isGrounded) {
      velocity = Offset(
        velocity.dx * friction,
        velocity.dy,
      );
    }

    if (fy < 0 && isGrounded) {
      isGrounded = false;
      useGravity = true;
    }
    notifyListeners();
  }

  void applyForceX(double fx, {double friction = 0.95}) => applyForce(fx: fx, friction: friction);

  void applyForceY(double fy, {double resistance = 0.98}) => applyForce(fy: fy, resistance: resistance);

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
    velocity = Offset(velocity.dx, 0); // Reset vertical velocity
    fallProgress = 0.0;
    gravity = 0.2; // Reset gravity to base value
    notifyListeners();
  }

  void leaveGround() {
    if (isStatic) return;
    isGrounded = false;
    useGravity = true;
    notifyListeners();
  }

  @override
  void update(Duration dt, {required Entity activeEntity}) {
  if (isStatic) return;

  checkIfGrounded(activeEntity);
  if (!isGrounded && useGravity) {
    fallProgress += gravityAccelerationRate;

    // Optional cap on fallProgress to prevent black hole gravity
    fallProgress = fallProgress.clamp(0, maxFallSpeed);

    velocity += Offset(0, gravity * fallProgress);
  }

  final dx = velocity.dx;
  final dy = velocity.dy;

  activeEntity.move(x: dx, y: dy);
}




  void checkIfGrounded(Entity entity) {
  
  final collider = entity.getComponent<ColliderComponent>();
  if (collider == null) return;

  final a = collider.getRect(entity);
  final onGround = EntityManager()
      .entities[EntityType.actors]!
      .values
      .any((other) {
    if (other == entity) return false;
    final otherCollider = other.getComponent<ColliderComponent>();
    if (otherCollider == null) return false;
    final b = otherCollider.getRect(other);
    final groundCheck = Rect.fromLTWH(a.left, a.bottom, a.width, 1);
    return groundCheck.overlaps(b) && a.center.dy < b.center.dy;
  });

  if (onGround) {
    landOnGround();
    log('Iam on ground');
  } else{
    leaveGround();
    log('Iam flying');
  }
}

  
  
}