// import 'package:scratch_clone/component/component.dart';
// import 'package:scratch_clone/entity/data/entity.dart';
// import 'package:scratch_clone/entity/data/entity_manager.dart';

// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as img;
// import 'dart:typed_data';
// import 'dart:math';

// class PoseDetectionComponent extends Component {
//   final String targetEntityName;
//   final String variableName;
//   final Map<String, dynamic> poseMappings;
//   final int updateIntervalMs;
//   final dynamic defaultValue;
//   final bool autoReset;

//   DateTime _lastUpdate = DateTime.now();
//   Interpreter? _interpreter;
//   CameraController? _cameraController;
//   bool _isInitialized = false;
//   String _lastDetectedPose = 'unknown';
  
//   // PoseNet model constants
//   static const int INPUT_SIZE = 257;
//   static const int OUTPUT_SIZE = 17; // 17 keypoints for PoseNet
//   static const double CONFIDENCE_THRESHOLD = 0.5;
  
//   // Keypoint indices (PoseNet standard)
//   static const Map<String, int> KEYPOINT_INDICES = {
//     'nose': 0, 'leftEye': 1, 'rightEye': 2, 'leftEar': 3, 'rightEar': 4,
//     'leftShoulder': 5, 'rightShoulder': 6, 'leftElbow': 7, 'rightElbow': 8,
//     'leftWrist': 9, 'rightWrist': 10, 'leftHip': 11, 'rightHip': 12,
//     'leftKnee': 13, 'rightKnee': 14, 'leftAnkle': 15, 'rightAnkle': 16
//   };

//   PoseDetectionComponent({
//     required this.targetEntityName,
//     required this.variableName,
//     required this.poseMappings,
//     this.updateIntervalMs = 300,
//     this.defaultValue,
//     this.autoReset = true,
//   });

//   @override
//   void init() async {
//     await _initializeTensorFlow();
//     await _initializeCamera();
//   }

//   Future<void> _initializeTensorFlow() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('assets/models/posenet_mobilenet_v1_100_257x257_multi_kpt_stripped.tflite');
//       _isInitialized = true;
//     } catch (e) {
//       print('Error initializing TensorFlow Lite: $e');
//     }
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         _cameraController = CameraController(
//           cameras.first,
//           ResolutionPreset.medium,
//           enableAudio: false,
//         );
//         await _cameraController?.initialize();
//       }
//     } catch (e) {
//       print('Error initializing camera: $e');
//     }
//   }

//   @override
//   void update(Duration dt, {required Entity activeEntity}) async {
//     final now = DateTime.now();
//     if (now.difference(_lastUpdate).inMilliseconds < updateIntervalMs) return;
//     _lastUpdate = now;

//     final detectedPose = await runPoseDetection();

//     final valueToSet = poseMappings[detectedPose] ?? defaultValue;

//     final entity = EntityManager().getActorByName(targetEntityName);
//     if (entity != null) {
//       entity.setVariableXToValueY(variableName, valueToSet);
//     }
//   }

//   Future<String> runPoseDetection() async {
//     if (!_isInitialized || _interpreter == null || _cameraController == null) {
//       return _lastDetectedPose;
//     }

//     try {
//       // Capture frame from camera
//       final image = await _cameraController!.takePicture();
//       final bytes = await image.readAsBytes();
      
//       // Preprocess image
//       final processedImage = await _preprocessImage(bytes);
      
//       // Run inference
//       final keypoints = await _runInference(processedImage);
      
//       // Analyze pose
//       final pose = _analyzePose(keypoints);
      
//       _lastDetectedPose = pose;
//       return pose;
//     } catch (e) {
//       print('Error in pose detection: $e');
//       return _lastDetectedPose;
//     }
//   }

//   Future<Float32List> _preprocessImage(Uint8List imageBytes) async {
//     // Decode image
//     final image = img.decodeImage(imageBytes)!;
    
//     // Resize to model input size
//     final resizedImage = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);
    
//     // Convert to float32 array and normalize
//     final input = Float32List(INPUT_SIZE * INPUT_SIZE * 3);
//     int index = 0;
    
//     for (int y = 0; y < INPUT_SIZE; y++) {
//       for (int x = 0; x < INPUT_SIZE; x++) {
//         final pixel = resizedImage.getPixel(x, y);
//         input[index++] = (img.getRed(pixel) / 255.0) * 2.0 - 1.0;
//         input[index++] = (img.getGreen(pixel) / 255.0) * 2.0 - 1.0;
//         input[index++] = (img.getBlue(pixel) / 255.0) * 2.0 - 1.0;
//       }
//     }
    
//     return input;
//   }

//   Future<List<List<double>>> _runInference(Float32List input) async {
//     // Prepare input tensor
//     final inputTensor = [input.reshape([1, INPUT_SIZE, INPUT_SIZE, 3])];
    
//     // Prepare output tensors
//     final heatmaps = List.generate(1, (i) => List.generate(9, (j) => List.generate(9, (k) => List.filled(OUTPUT_SIZE, 0.0))));
//     final offsets = List.generate(1, (i) => List.generate(9, (j) => List.generate(9, (k) => List.filled(OUTPUT_SIZE * 2, 0.0))));
    
//     // Run inference
//     _interpreter!.runForMultipleInputs(inputTensor, {
//       0: heatmaps,
//       1: offsets,
//     });
    
//     // Extract keypoints from heatmaps and offsets
//     return _extractKeypoints(heatmaps[0], offsets[0]);
//   }

//   List<List<double>> _extractKeypoints(List<List<List<double>>> heatmaps, List<List<List<double>>> offsets) {
//     final keypoints = <List<double>>[];
    
//     for (int i = 0; i < OUTPUT_SIZE; i++) {
//       double maxVal = 0;
//       int maxRow = 0, maxCol = 0;
      
//       // Find maximum value in heatmap for this keypoint
//       for (int row = 0; row < 9; row++) {
//         for (int col = 0; col < 9; col++) {
//           if (heatmaps[row][col][i] > maxVal) {
//             maxVal = heatmaps[row][col][i];
//             maxRow = row;
//             maxCol = col;
//           }
//         }
//       }
      
//       // Calculate actual position with offset
//       final y = maxRow * (INPUT_SIZE / 9) + offsets[maxRow][maxCol][i];
//       final x = maxCol * (INPUT_SIZE / 9) + offsets[maxRow][maxCol][i + OUTPUT_SIZE];
      
//       keypoints.add([x, y, maxVal]);
//     }
    
//     return keypoints;
//   }

//   String _analyzePose(List<List<double>> keypoints) {
//     // Basic pose classification based on keypoint positions
//     if (_isWaving(keypoints)) return 'waving';
//     if (_isJumping(keypoints)) return 'jumping';
//     if (_isCrouching(keypoints)) return 'crouching';
//     if (_isRaisingArms(keypoints)) return 'arms_up';
//     if (_isStanding(keypoints)) return 'standing';
    
//     return 'unknown';
//   }

//   bool _isWaving(List<List<double>> keypoints) {
//     final rightWrist = keypoints[KEYPOINT_INDICES['rightWrist']!];
//     final rightShoulder = keypoints[KEYPOINT_INDICES['rightShoulder']!];
//     final rightElbow = keypoints[KEYPOINT_INDICES['rightElbow']!];
    
//     // Check if confidence is high enough
//     if (rightWrist[2] < CONFIDENCE_THRESHOLD || rightShoulder[2] < CONFIDENCE_THRESHOLD || rightElbow[2] < CONFIDENCE_THRESHOLD) {
//       return false;
//     }
    
//     // Waving: wrist above shoulder and elbow bent
//     return rightWrist[1] < rightShoulder[1] && rightWrist[1] < rightElbow[1];
//   }

//   bool _isJumping(List<List<double>> keypoints) {
//     final leftAnkle = keypoints[KEYPOINT_INDICES['leftAnkle']!];
//     final rightAnkle = keypoints[KEYPOINT_INDICES['rightAnkle']!];
//     final leftKnee = keypoints[KEYPOINT_INDICES['leftKnee']!];
//     final rightKnee = keypoints[KEYPOINT_INDICES['rightKnee']!];
    
//     if (leftAnkle[2] < CONFIDENCE_THRESHOLD || rightAnkle[2] < CONFIDENCE_THRESHOLD ||
//         leftKnee[2] < CONFIDENCE_THRESHOLD || rightKnee[2] < CONFIDENCE_THRESHOLD) {
//       return false;
//     }
    
//     // Jumping: feet elevated and knees bent
//     return leftAnkle[1] < leftKnee[1] && rightAnkle[1] < rightKnee[1];
//   }

//   bool _isCrouching(List<List<double>> keypoints) {
//     final leftKnee = keypoints[KEYPOINT_INDICES['leftKnee']!];
//     final rightKnee = keypoints[KEYPOINT_INDICES['rightKnee']!];
//     final leftHip = keypoints[KEYPOINT_INDICES['leftHip']!];
//     final rightHip = keypoints[KEYPOINT_INDICES['rightHip']!];
    
//     if (leftKnee[2] < CONFIDENCE_THRESHOLD || rightKnee[2] < CONFIDENCE_THRESHOLD ||
//         leftHip[2] < CONFIDENCE_THRESHOLD || rightHip[2] < CONFIDENCE_THRESHOLD) {
//       return false;
//     }
    
//     // Crouching: knees close to hip level
//     final avgKneeY = (leftKnee[1] + rightKnee[1]) / 2;
//     final avgHipY = (leftHip[1] + rightHip[1]) / 2;
    
//     return (avgKneeY - avgHipY).abs() < 50;
//   }

//   bool _isRaisingArms(List<List<double>> keypoints) {
//     final leftWrist = keypoints[KEYPOINT_INDICES['leftWrist']!];
//     final rightWrist = keypoints[KEYPOINT_INDICES['rightWrist']!];
//     final leftShoulder = keypoints[KEYPOINT_INDICES['leftShoulder']!];
//     final rightShoulder = keypoints[KEYPOINT_INDICES['rightShoulder']!];
    
//     if (leftWrist[2] < CONFIDENCE_THRESHOLD || rightWrist[2] < CONFIDENCE_THRESHOLD ||
//         leftShoulder[2] < CONFIDENCE_THRESHOLD || rightShoulder[2] < CONFIDENCE_THRESHOLD) {
//       return false;
//     }
    
//     // Both arms raised: both wrists above shoulders
//     return leftWrist[1] < leftShoulder[1] && rightWrist[1] < rightShoulder[1];
//   }

//   bool _isStanding(List<List<double>> keypoints) {
//     final leftAnkle = keypoints[KEYPOINT_INDICES['leftAnkle']!];
//     final rightAnkle = keypoints[KEYPOINT_INDICES['rightAnkle']!];
//     final leftKnee = keypoints[KEYPOINT_INDICES['leftKnee']!];
//     final rightKnee = keypoints[KEYPOINT_INDICES['rightKnee']!];
//     final leftHip = keypoints[KEYPOINT_INDICES['leftHip']!];
//     final rightHip = keypoints[KEYPOINT_INDICES['rightHip']!];
    
//     if (leftAnkle[2] < CONFIDENCE_THRESHOLD || rightAnkle[2] < CONFIDENCE_THRESHOLD ||
//         leftKnee[2] < CONFIDENCE_THRESHOLD || rightKnee[2] < CONFIDENCE_THRESHOLD ||
//         leftHip[2] < CONFIDENCE_THRESHOLD || rightHip[2] < CONFIDENCE_THRESHOLD) {
//       return false;
//     }
    
//     // Standing: relatively straight legs
//     final leftLegStraight = (leftHip[1] - leftKnee[1]) > 0 && (leftKnee[1] - leftAnkle[1]) > 0;
//     final rightLegStraight = (rightHip[1] - rightKnee[1]) > 0 && (rightKnee[1] - rightAnkle[1]) > 0;
    
//     return leftLegStraight && rightLegStraight;
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'PoseDetectionComponent',
//       'targetEntityName': targetEntityName,
//       'variableName': variableName,
//       'poseMappings': poseMappings,
//       'updateIntervalMs': updateIntervalMs,
//       'defaultValue': defaultValue,
//       'autoReset': autoReset,
//     };
//   }

//   static PoseDetectionComponent fromJson(Map<String, dynamic> json) {
//     return PoseDetectionComponent(
//       targetEntityName: json['targetEntityName'],
//       variableName: json['variableName'],
//       poseMappings: Map<String, dynamic>.from(json['poseMappings']),
//       updateIntervalMs: json['updateIntervalMs'] ?? 300,
//       defaultValue: json['defaultValue'],
//       autoReset: json['autoReset'] ?? true,
//     );
//   }

//   @override
//   Component copy() => fromJson(toJson());
  
//   @override
//   void reset() {
//     _lastDetectedPose = 'unknown';
//     _lastUpdate = DateTime.now();
//   }

//   @override
//   void dispose() {
//     _interpreter?.close();
//     _cameraController?.dispose();
//   }
// }