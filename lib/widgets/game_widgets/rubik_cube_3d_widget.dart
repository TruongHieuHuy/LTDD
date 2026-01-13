import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import '../../models/rubik_cube_model.dart';

class RubikCube3DWidget extends StatefulWidget {
  final RubikCubeModel cube;
  final double size;

  const RubikCube3DWidget({
    super.key,
    required this.cube,
    this.size = 300.0,
  });

  @override
  State<RubikCube3DWidget> createState() => RubikCube3DWidgetState();
}

class RubikCube3DWidgetState extends State<RubikCube3DWidget>
    with TickerProviderStateMixin {
  late Scene _scene;
  late List<List<List<Object>>> _cubes = [];
  bool _isRotating = false;
  AnimationController? _rotationController;
  Animation<double>? _rotationAnimation;
  
  // Camera orbit variables
  Offset? _lastFocalPoint;
  double _cameraDistance = 25.0;
  double _cameraAngleX = 0.3;
  double _cameraAngleY = 0.7;

  @override
  void initState() {
    super.initState();
    _initializeCubesArray();
    widget.cube.addListener(_onCubeChanged);
  }

  @override
  void dispose() {
    widget.cube.removeListener(_onCubeChanged);
    _rotationController?.dispose();
    super.dispose();
  }

  void _onCubeChanged() {
    // Sync colors from model to 3D cubes
    _updateCubeColors();
  }

  void _initializeCubesArray() {
    _cubes = List.generate(
      3,
      (x) => List.generate(
        3,
        (y) => List.generate(3, (z) => Object(name: 'temp')),
      ),
    );
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        for (int z = 0; z < 3; z++) {
          final mesh = Mesh(
            vertices: _createCubeVertices(),
            texcoords: _createCubeTexcoords(),
            indices: _createCubeIndices(),
            colors: _getCubeColors(x, y, z),
          );

          final obj = Object(
            name: 'cube_${x}_${y}_$z',
            mesh: mesh,
            position: Vector3((x - 1) * 2.2, (y - 1) * 2.2, (z - 1) * 2.2),
            scale: Vector3(0.95, 0.95, 0.95),
          );

          scene.world.add(obj);
          _cubes[x][y][z] = obj;
        }
      }
    }

    _updateCameraPosition();
    scene.camera.target.setValues(0, 0, 0);
    scene.light.position.setFrom(Vector3(15, 15, 15));
  }
  
  void _updateCameraPosition() {
    if (!mounted) return;
    final x = _cameraDistance * math.cos(_cameraAngleX) * math.sin(_cameraAngleY);
    final y = _cameraDistance * math.sin(_cameraAngleX);
    final z = _cameraDistance * math.cos(_cameraAngleX) * math.cos(_cameraAngleY);
    
    if (_scene.world.children.isNotEmpty) {
      _scene.camera.position.setValues(x, y, z);
      _scene.camera.target.setValues(0, 0, 0);
    }
  }
  
  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
  }
  
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final currentFocal = details.focalPoint;
    
    // Handle pan (drag to rotate camera)
    if (_lastFocalPoint != null) {
      final delta = currentFocal - _lastFocalPoint!;
      _cameraAngleY += delta.dx * 0.01;
      _cameraAngleX += delta.dy * 0.01;
      _cameraAngleX = _cameraAngleX.clamp(
        -math.pi / 2 + 0.1,
        math.pi / 2 - 0.1,
      );
    }
    _lastFocalPoint = currentFocal;
    
    // Handle scale (pinch zoom)
    if (details.scale != 1.0) {
      final scaleFactor = details.scale > 1.0 ? 0.95 : 1.05;
      _cameraDistance *= scaleFactor;
      _cameraDistance = _cameraDistance.clamp(10.0, 50.0);
    }
    
    _updateCameraPosition();
    setState(() {});
  }
  
  void _onScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
  }

  List<Vector3> _createCubeVertices() {
    return [
      Vector3(-1, -1, 1),
      Vector3(1, -1, 1),
      Vector3(1, 1, 1),
      Vector3(-1, 1, 1),
      Vector3(-1, -1, -1),
      Vector3(-1, 1, -1),
      Vector3(1, 1, -1),
      Vector3(1, -1, -1),
      Vector3(-1, 1, -1),
      Vector3(-1, 1, 1),
      Vector3(1, 1, 1),
      Vector3(1, 1, -1),
      Vector3(-1, -1, -1),
      Vector3(1, -1, -1),
      Vector3(1, -1, 1),
      Vector3(-1, -1, 1),
      Vector3(1, -1, -1),
      Vector3(1, 1, -1),
      Vector3(1, 1, 1),
      Vector3(1, -1, 1),
      Vector3(-1, -1, -1),
      Vector3(-1, -1, 1),
      Vector3(-1, 1, 1),
      Vector3(-1, 1, -1),
    ];
  }

  List<Offset> _createCubeTexcoords() {
    return List.generate(24, (i) => const Offset(0, 0));
  }

  List<Polygon> _createCubeIndices() {
    List<Polygon> indices = [];
    for (int i = 0; i < 6; i++) {
      int offset = i * 4;
      indices.add(Polygon(offset, offset + 1, offset + 2));
      indices.add(Polygon(offset, offset + 2, offset + 3));
    }
    return indices;
  }

  List<Color> _getCubeColors(int x, int y, int z) {
    final cubelet = widget.cube.cubelets[x][y][z];
    List<Color> colors = [];

    // Front face (z = 2)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('front');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    // Back face (z = 0)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('back');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    // Top face (y = 2)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('up');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    // Bottom face (y = 0)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('down');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    // Right face (x = 2)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('right');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    // Left face (x = 0)
    for (int i = 0; i < 4; i++) {
      final color = cubelet.getFaceColor('left');
      colors.add(color != null
          ? cubelet.getFlutterColor(color)
          : Colors.grey[900]!);
    }

    return colors;
  }

  void _updateCubeColors() {
    if (_scene.world.children.isEmpty) return;

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        for (int z = 0; z < 3; z++) {
          final obj = _cubes[x][y][z];
          obj.mesh.colors = _getCubeColors(x, y, z);
        }
      }
    }
    _scene.updateTexture();
  }

  void _rotateFace({
    required List<Object> Function() getCubes,
    required Vector3 axis,
    required bool clockwise,
    required Function swapPositions,
  }) {
    if (_isRotating) return;

    setState(() => _isRotating = true);

    final cubes = getCubes();
    final angle = clockwise ? -math.pi / 2 : math.pi / 2;

    final initialPositions =
        cubes.map((c) => Vector3.copy(c.position)).toList();
    final initialRotations =
        cubes.map((c) => Vector3.copy(c.rotation)).toList();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Tăng từ 300ms lên 500ms
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: angle)
        .animate(CurvedAnimation(
      parent: _rotationController!,
      curve: Curves.fastOutSlowIn, // Curve mượt hơn
    ));

    _rotationAnimation!.addListener(() {
      final currentAngle = _rotationAnimation!.value;
      for (int i = 0; i < cubes.length; i++) {
        final obj = cubes[i];
        final rotatedPos = _rotatePointAroundAxis(
          initialPositions[i],
          axis,
          currentAngle,
        );
        obj.position.setFrom(rotatedPos);

        if (axis.x != 0) {
          obj.rotation.x = initialRotations[i].x + currentAngle;
        } else if (axis.y != 0) {
          obj.rotation.y = initialRotations[i].y + currentAngle;
        } else {
          obj.rotation.z = initialRotations[i].z + currentAngle;
        }
      }
      _scene.updateTexture();
    });

    _rotationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        swapPositions();
        _updateCubeColors();
        setState(() => _isRotating = false);
        _rotationController?.dispose();
        _rotationController = null;
      }
    });

    _rotationController!.forward();
  }

  Vector3 _rotatePointAroundAxis(Vector3 point, Vector3 axis, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    final x = point.x, y = point.y, z = point.z;

    if (axis.x != 0) {
      return Vector3(x, cos * y - sin * z, sin * y + cos * z);
    } else if (axis.y != 0) {
      return Vector3(cos * x + sin * z, y, -sin * x + cos * z);
    } else {
      return Vector3(cos * x - sin * y, sin * x + cos * y, z);
    }
  }

  // Expose rotation methods to be called from parent
  void rotateFace(String face, bool clockwise) {
    switch (face) {
      case 'front':
        _rotateFront(clockwise);
        break;
      case 'back':
        _rotateBack(clockwise);
        break;
      case 'left':
        _rotateLeft(clockwise);
        break;
      case 'right':
        _rotateRight(clockwise);
        break;
      case 'up':
        _rotateTop(clockwise);
        break;
      case 'down':
        _rotateBottom(clockwise);
        break;
      case 'middle_x': // M
        _rotateMiddleX(clockwise);
        break;
      case 'middle_y': // E
        _rotateMiddleY(clockwise);
        break;
      case 'middle_z': // S
        _rotateMiddleZ(clockwise);
        break;
    }
  }

  void _rotateFront(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int y = 0; y < 3; y++) {
            cubes.add(_cubes[x][y][2]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 0, 1),
      clockwise: clockwise,
      swapPositions: () {
        // Update model
        widget.cube.rotateFace('front', clockwise);
      },
    );
  }

  void _rotateBack(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int y = 0; y < 3; y++) {
            cubes.add(_cubes[x][y][0]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 0, 1),
      clockwise: !clockwise,
      swapPositions: () {
        widget.cube.rotateFace('back', clockwise);
      },
    );
  }

  void _rotateLeft(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int y = 0; y < 3; y++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[0][y][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(1, 0, 0),
      clockwise: !clockwise,
      swapPositions: () {
        widget.cube.rotateFace('left', clockwise);
      },
    );
  }

  void _rotateRight(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int y = 0; y < 3; y++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[2][y][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(1, 0, 0),
      clockwise: clockwise,
      swapPositions: () {
        widget.cube.rotateFace('right', clockwise);
      },
    );
  }

  void _rotateTop(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[x][2][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 1, 0),
      clockwise: clockwise,
      swapPositions: () {
        widget.cube.rotateFace('up', clockwise);
      },
    );
  }

  void _rotateBottom(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[x][0][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 1, 0),
      clockwise: !clockwise,
      swapPositions: () {
        widget.cube.rotateFace('down', clockwise);
      },
    );
  }

  void _rotateMiddleX(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int y = 0; y < 3; y++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[1][y][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(1, 0, 0),
      clockwise: !clockwise,
      swapPositions: () {
        widget.cube.rotateFace('middle_x', clockwise);
      },
    );
  }

  void _rotateMiddleY(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int z = 0; z < 3; z++) {
            cubes.add(_cubes[x][1][z]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 1, 0),
      clockwise: !clockwise,
      swapPositions: () {
        widget.cube.rotateFace('middle_y', clockwise);
      },
    );
  }

  void _rotateMiddleZ(bool clockwise) {
    _rotateFace(
      getCubes: () {
        List<Object> cubes = [];
        for (int x = 0; x < 3; x++) {
          for (int y = 0; y < 3; y++) {
            cubes.add(_cubes[x][y][1]);
          }
        }
        return cubes;
      },
      axis: Vector3(0, 0, 1),
      clockwise: clockwise,
      swapPositions: () {
        widget.cube.rotateFace('middle_z', clockwise);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Cube(
            onSceneCreated: _onSceneCreated,
            interactive: false, // Tắt để tối ưu hiệu năng, dùng gesture detector
          ),
        ),
      ),
    );
  }
}

