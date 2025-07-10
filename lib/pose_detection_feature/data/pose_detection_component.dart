import 'dart:ffi';

import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:math';
import 'dart:developer' as dev;

// class PoseDetectionComponent extends Component {
//   Map<String, String> poseMappings = {'isWaving': 'waving'};
//   final int updateIntervalMs;
//   final dynamic defaultValue;
//   final bool autoReset;

//   DateTime _lastUpdate = DateTime.now();
//   Interpreter? _interpreter;
//   CameraController? _cameraController;
//   bool _isInitialized = false;
//   bool _isProcessing = false;
//   bool _isStreaming = false;
//   String _lastDetectedPose = 'unknown';

//   static const int INPUT_SIZE = 257;
//   static const int OUTPUT_SIZE = 17;
//   static const double CONFIDENCE_THRESHOLD = 0.5;

//   static const Map<String, int> KEYPOINT_INDICES = {
//     'nose': 0,
//     'leftEye': 1,
//     'rightEye': 2,
//     'leftEar': 3,
//     'rightEar': 4,
//     'leftShoulder': 5,
//     'rightShoulder': 6,
//     'leftElbow': 7,
//     'rightElbow': 8,
//     'leftWrist': 9,
//     'rightWrist': 10,
//     'leftHip': 11,
//     'rightHip': 12,
//     'leftKnee': 13,
//     'rightKnee': 14,
//     'leftAnkle': 15,
//     'rightAnkle': 16
//   };

//   PoseDetectionComponent({
    
//     this.updateIntervalMs = 300,
//     this.defaultValue,
//     this.autoReset = true,
//   });

//   void init() async {
//     await _initializeTensorFlow();
//     await _initializeCamera();
//     _startStreaming();
//   }

//   void _startStreaming() {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     if (_isStreaming) return;

//     _cameraController!.startImageStream((CameraImage image) async {
//       if (_isProcessing || !_isInitialized) return;

//       final now = DateTime.now();
//       if (now.difference(_lastUpdate).inMilliseconds < updateIntervalMs) return;
//       _lastUpdate = now;

//       _isProcessing = true;
//       try {
//         final detectedPose = await _processFrame(image);
//         _lastDetectedPose = detectedPose;
//       } catch (e) {
//         dev.log("Pose detection error: $e");
//       } finally {
//         _isProcessing = false;
//       }
//     });

//     _isStreaming = true;
//   }

//   Future<void> _initializeTensorFlow() async {
//     try {
//       _interpreter = await Interpreter.fromAsset(
//         'assets/models/posenet_mobilenet_v1_100_257x257_multi_kpt_stripped.tflite',
//       );
//       _isInitialized = true;
//     } catch (e) {
//       dev.log('Error initializing TensorFlow Lite: $e');
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
//         await _cameraController!.initialize();
//       }
//     } catch (e) {
//       dev.log('Error initializing camera: $e');
//     }
//   }

//   Future<String> _processFrame(CameraImage image) async {
//     try {
//       // 1. Convert YUV420 image to RGB image
//       final rgbImage = _convertYUV420toImage(image);
//       if (rgbImage == null) {
//         dev.log("Failed to convert YUV420 to RGB");
//         return _lastDetectedPose;
//       }

//       // 2. Resize to 257x257
//       final resized = img.copyResize(rgbImage, width: INPUT_SIZE, height: INPUT_SIZE);

//       // 3. Normalize and prepare input tensor
//       final input = Float32List(INPUT_SIZE * INPUT_SIZE * 3);
//       int index = 0;
//       for (int y = 0; y < INPUT_SIZE; y++) {
//         for (int x = 0; x < INPUT_SIZE; x++) {
//           final pixel = resized.getPixel(x, y);
//           final r = pixel.r;
//           final g = pixel.g;
//           final b = pixel.b;

//           input[index++] = (r / 255.0) * 2 - 1.0;
//           input[index++] = (g / 255.0) * 2 - 1.0;
//           input[index++] = (b / 255.0) * 2 - 1.0;
//         }
//       }

//       // 4. Run inference
//       final keypoints = await _runInference(input);

//       // 5. Analyze keypoints and return pose name
//       return _analyzePose(keypoints);
//     } catch (e) {
//       dev.log("Error in _processFrame: $e");
//       return _lastDetectedPose;
//     }
//   }

//   img.Image? _convertYUV420toImage(CameraImage image) {
//     try {
//       final width = image.width;
//       final height = image.height;
      
//       // Check if we have the required planes
//       if (image.planes.length < 3) {
//         dev.log("Invalid camera image: insufficient planes");
//         return null;
//       }

//       final yPlane = image.planes[0];
//       final uPlane = image.planes[1];
//       final vPlane = image.planes[2];

//       // Safety checks
//       if (yPlane.bytes.isEmpty || uPlane.bytes.isEmpty || vPlane.bytes.isEmpty) {
//         dev.log("Invalid camera image: empty plane data");
//         return null;
//       }

//       final uvRowStride = uPlane.bytesPerRow;
//       final uvPixelStride = uPlane.bytesPerPixel ?? 1;

//       final imgImage = img.Image(width: width, height: height);

//       for (int y = 0; y < height; y++) {
//         for (int x = 0; x < width; x++) {
//           final uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
//           final yIndex = y * yPlane.bytesPerRow + x;

//           // Bounds checking
//           if (yIndex >= yPlane.bytes.length || 
//               uvIndex >= uPlane.bytes.length || 
//               uvIndex >= vPlane.bytes.length) {
//             continue;
//           }

//           final yValue = yPlane.bytes[yIndex];
//           final uValue = uPlane.bytes[uvIndex];
//           final vValue = vPlane.bytes[uvIndex];

//           final r = (yValue + 1.370705 * (vValue - 128)).clamp(0, 255).toInt();
//           final g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128)).clamp(0, 255).toInt();
//           final b = (yValue + 1.732446 * (uValue - 128)).clamp(0, 255).toInt();

//           imgImage.setPixelRgb(x, y, r, g, b);
//         }
//       }

//       return imgImage;
//     } catch (e) {
//       dev.log("Error converting YUV420 to Image: $e");
//       return null;
//     }
//   }

//   Future<List<List<double>>> _runInference(Float32List input) async {
//     try {
//       if (_interpreter == null) {
//         throw Exception("Interpreter not initialized");
//       }

//       final inputTensor = input.reshape([1, INPUT_SIZE, INPUT_SIZE, 3]);

//       final heatmaps = List.generate(
//           1, (_) => List.generate(9, (_) => List.generate(9, (_) => List.filled(OUTPUT_SIZE, 0.0))));
//       final offsets = List.generate(
//           1, (_) => List.generate(9, (_) => List.generate(9, (_) => List.filled(OUTPUT_SIZE * 2, 0.0))));

//       _interpreter!.runForMultipleInputs([inputTensor], {
//         0: heatmaps,
//         1: offsets,
//       });

//       return _extractKeypoints(heatmaps[0], offsets[0]);
//     } catch (e) {
//       dev.log("Error in _runInference: $e");
//       return [];
//     }
//   }

//   List<List<double>> _extractKeypoints(List<List<List<double>>> heatmaps, List<List<List<double>>> offsets) {
//     final keypoints = <List<double>>[];

//     try {
//       for (int i = 0; i < OUTPUT_SIZE; i++) {
//         double maxVal = 0;
//         int maxRow = 0, maxCol = 0;

//         for (int row = 0; row < 9; row++) {
//           for (int col = 0; col < 9; col++) {
//             if (heatmaps[row][col][i] > maxVal) {
//               maxVal = heatmaps[row][col][i];
//               maxRow = row;
//               maxCol = col;
//             }
//           }
//         }

//         final y = maxRow * (INPUT_SIZE / 9) + offsets[maxRow][maxCol][i];
//         final x = maxCol * (INPUT_SIZE / 9) + offsets[maxRow][maxCol][i + OUTPUT_SIZE];
//         keypoints.add([x, y, maxVal]);
//       }
//     } catch (e) {
//       dev.log("Error extracting keypoints: $e");
//     }

//     return keypoints;
//   }

//   String _analyzePose(List<List<double>> keypoints) {
//     if (keypoints.isEmpty) return 'unknown';
    
//     try {
//       if (_isWaving(keypoints)) return 'waving';
//       if (_isJumping(keypoints)) return 'jumping';
//       if (_isCrouching(keypoints)) return 'crouching';
//       if (_isRaisingArms(keypoints)) return 'arms_up';
//       if (_isStanding(keypoints)) return 'standing';
//     } catch (e) {
//       dev.log("Error analyzing pose: $e");
//     }
    
//     return 'unknown';
//   }

//   bool _isWaving(List<List<double>> k) {
//     try {
//       final rightWristIdx = KEYPOINT_INDICES['rightWrist'];
//       final rightShoulderIdx = KEYPOINT_INDICES['rightShoulder'];
//       final rightElbowIdx = KEYPOINT_INDICES['rightElbow'];
      
//       if (rightWristIdx == null || rightShoulderIdx == null || rightElbowIdx == null) {
//         return false;
//       }
      
//       if (k.length <= rightWristIdx || k.length <= rightShoulderIdx || k.length <= rightElbowIdx) {
//         return false;
//       }
      
//       final w = k[rightWristIdx];
//       final s = k[rightShoulderIdx];
//       final e = k[rightElbowIdx];
      
//       if (w.length < 3 || s.length < 3 || e.length < 3) {
//         return false;
//       }
      
//       return w[2] > CONFIDENCE_THRESHOLD &&
//           s[2] > CONFIDENCE_THRESHOLD &&
//           e[2] > CONFIDENCE_THRESHOLD &&
//           w[1] < s[1] &&
//           w[1] < e[1];
//     } catch (e) {
//       dev.log("Error in _isWaving: $e");
//       return false;
//     }
//   }

//   bool _isJumping(List<List<double>> k) {
//     try {
//       final leftAnkleIdx = KEYPOINT_INDICES['leftAnkle'];
//       final rightAnkleIdx = KEYPOINT_INDICES['rightAnkle'];
//       final leftKneeIdx = KEYPOINT_INDICES['leftKnee'];
//       final rightKneeIdx = KEYPOINT_INDICES['rightKnee'];
      
//       if (leftAnkleIdx == null || rightAnkleIdx == null || leftKneeIdx == null || rightKneeIdx == null) {
//         return false;
//       }
      
//       if (k.length <= leftAnkleIdx || k.length <= rightAnkleIdx || k.length <= leftKneeIdx || k.length <= rightKneeIdx) {
//         return false;
//       }
      
//       final la = k[leftAnkleIdx];
//       final ra = k[rightAnkleIdx];
//       final lk = k[leftKneeIdx];
//       final rk = k[rightKneeIdx];
      
//       if (la.length < 3 || ra.length < 3 || lk.length < 3 || rk.length < 3) {
//         return false;
//       }
      
//       return la[2] > CONFIDENCE_THRESHOLD &&
//           ra[2] > CONFIDENCE_THRESHOLD &&
//           lk[2] > CONFIDENCE_THRESHOLD &&
//           rk[2] > CONFIDENCE_THRESHOLD &&
//           la[1] < lk[1] &&
//           ra[1] < rk[1];
//     } catch (e) {
//       dev.log("Error in _isJumping: $e");
//       return false;
//     }
//   }

//   bool _isCrouching(List<List<double>> k) {
//     try {
//       final leftHipIdx = KEYPOINT_INDICES['leftHip'];
//       final rightHipIdx = KEYPOINT_INDICES['rightHip'];
//       final leftKneeIdx = KEYPOINT_INDICES['leftKnee'];
//       final rightKneeIdx = KEYPOINT_INDICES['rightKnee'];
      
//       if (leftHipIdx == null || rightHipIdx == null || leftKneeIdx == null || rightKneeIdx == null) {
//         return false;
//       }
      
//       if (k.length <= leftHipIdx || k.length <= rightHipIdx || k.length <= leftKneeIdx || k.length <= rightKneeIdx) {
//         return false;
//       }
      
//       final lh = k[leftHipIdx];
//       final rh = k[rightHipIdx];
//       final lk = k[leftKneeIdx];
//       final rk = k[rightKneeIdx];
      
//       if (lh.length < 3 || rh.length < 3 || lk.length < 3 || rk.length < 3) {
//         return false;
//       }
      
//       if (lh[2] < CONFIDENCE_THRESHOLD || rh[2] < CONFIDENCE_THRESHOLD || 
//           lk[2] < CONFIDENCE_THRESHOLD || rk[2] < CONFIDENCE_THRESHOLD) {
//         return false;
//       }
      
//       final avgKneeY = (lk[1] + rk[1]) / 2;
//       final avgHipY = (lh[1] + rh[1]) / 2;
//       return (avgKneeY - avgHipY).abs() < 50;
//     } catch (e) {
//       dev.log("Error in _isCrouching: $e");
//       return false;
//     }
//   }

//   bool _isRaisingArms(List<List<double>> k) {
//     try {
//       final leftWristIdx = KEYPOINT_INDICES['leftWrist'];
//       final rightWristIdx = KEYPOINT_INDICES['rightWrist'];
//       final leftShoulderIdx = KEYPOINT_INDICES['leftShoulder'];
//       final rightShoulderIdx = KEYPOINT_INDICES['rightShoulder'];
      
//       if (leftWristIdx == null || rightWristIdx == null || leftShoulderIdx == null || rightShoulderIdx == null) {
//         return false;
//       }
      
//       if (k.length <= leftWristIdx || k.length <= rightWristIdx || k.length <= leftShoulderIdx || k.length <= rightShoulderIdx) {
//         return false;
//       }
      
//       final lw = k[leftWristIdx];
//       final rw = k[rightWristIdx];
//       final ls = k[leftShoulderIdx];
//       final rs = k[rightShoulderIdx];
      
//       if (lw.length < 3 || rw.length < 3 || ls.length < 3 || rs.length < 3) {
//         return false;
//       }
      
//       return lw[2] > CONFIDENCE_THRESHOLD &&
//           rw[2] > CONFIDENCE_THRESHOLD &&
//           ls[2] > CONFIDENCE_THRESHOLD &&
//           rs[2] > CONFIDENCE_THRESHOLD &&
//           lw[1] < ls[1] &&
//           rw[1] < rs[1];
//     } catch (e) {
//       dev.log("Error in _isRaisingArms: $e");
//       return false;
//     }
//   }

//   bool _isStanding(List<List<double>> k) {
//     try {
//       final leftAnkleIdx = KEYPOINT_INDICES['leftAnkle'];
//       final rightAnkleIdx = KEYPOINT_INDICES['rightAnkle'];
//       final leftKneeIdx = KEYPOINT_INDICES['leftKnee'];
//       final rightKneeIdx = KEYPOINT_INDICES['rightKnee'];
//       final leftHipIdx = KEYPOINT_INDICES['leftHip'];
//       final rightHipIdx = KEYPOINT_INDICES['rightHip'];
      
//       if (leftAnkleIdx == null || rightAnkleIdx == null || leftKneeIdx == null || 
//           rightKneeIdx == null || leftHipIdx == null || rightHipIdx == null) {
//         return false;
//       }
      
//       if (k.length <= leftAnkleIdx || k.length <= rightAnkleIdx || k.length <= leftKneeIdx || 
//           k.length <= rightKneeIdx || k.length <= leftHipIdx || k.length <= rightHipIdx) {
//         return false;
//       }
      
//       final la = k[leftAnkleIdx];
//       final ra = k[rightAnkleIdx];
//       final lk = k[leftKneeIdx];
//       final rk = k[rightKneeIdx];
//       final lh = k[leftHipIdx];
//       final rh = k[rightHipIdx];
      
//       if (la.length < 3 || ra.length < 3 || lk.length < 3 || 
//           rk.length < 3 || lh.length < 3 || rh.length < 3) {
//         return false;
//       }
      
//       final leftLeg = (lh[1] - lk[1]) > 0 && (lk[1] - la[1]) > 0;
//       final rightLeg = (rh[1] - rk[1]) > 0 && (rk[1] - ra[1]) > 0;
      
//       return la[2] > CONFIDENCE_THRESHOLD &&
//           ra[2] > CONFIDENCE_THRESHOLD &&
//           lk[2] > CONFIDENCE_THRESHOLD &&
//           rk[2] > CONFIDENCE_THRESHOLD &&
//           lh[2] > CONFIDENCE_THRESHOLD &&
//           rh[2] > CONFIDENCE_THRESHOLD &&
//           leftLeg &&
//           rightLeg;
//     } catch (e) {
//       dev.log("Error in _isStanding: $e");
//       return false;
//     }
//   }

//   void addPose(String pose, String variable) {
//     poseMappings[pose] = variable;
//     notifyListeners();
//   }

//   void removePose(String pose) {
//     poseMappings.remove(pose);
//     notifyListeners();
//   }

//   @override
//   void update(Duration dt, {required Entity activeEntity}) {
//     final variableName = poseMappings[_lastDetectedPose];
//     if (variableName != null && activeEntity.variables.containsKey(variableName)) {
//       activeEntity.setVariableXToValueY(variableName, true);
//     }
//   }

//   @override
//   Map<String, dynamic> toJson() => {
//         'type': 'PoseDetectionComponent',
//         'poseMappings': poseMappings,
//         'updateIntervalMs': updateIntervalMs,
//         'defaultValue': defaultValue,
//         'autoReset': autoReset,
//       };

//   static PoseDetectionComponent fromJson(Map<String, dynamic> json) {
//     return PoseDetectionComponent(
      
//       updateIntervalMs: json['updateIntervalMs'] ?? 300,
//       defaultValue: json['defaultValue'],
//       autoReset: json['autoReset'] ?? true,
//     ).. poseMappings = Map<String, String>.from(json['poseMappings']);
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
//     _cameraController?.stopImageStream();
//     _cameraController?.dispose();
//     _interpreter?.close();
//     _isStreaming = false;
//     _isInitialized = false;
//   }
// }
