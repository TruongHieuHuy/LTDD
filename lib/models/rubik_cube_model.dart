import 'package:flutter/material.dart';

enum CubeColor { white, red, blue, orange, green, yellow }

class Cubelet {
  final int x, y, z;
  Map<String, CubeColor> faces;

  Cubelet({required this.x, required this.y, required this.z}) : faces = {};

  void setFaceColor(String face, CubeColor color) {
    faces[face] = color;
  }

  CubeColor? getFaceColor(String face) {
    return faces[face];
  }

  Color getFlutterColor(CubeColor color) {
    switch (color) {
      case CubeColor.white:
        return const Color(0xFFFFFFF0);
      case CubeColor.red:
        return const Color(0xFFB71C1C);
      case CubeColor.blue:
        return const Color(0xFF0D47A1);
      case CubeColor.orange:
        return const Color(0xFFFF6F00);
      case CubeColor.green:
        return const Color(0xFF2E7D32);
      case CubeColor.yellow:
        return const Color(0xFFFDD835);
    }
  }
}

class RubikCubeModel extends ChangeNotifier {
  List<List<List<Cubelet>>> cubelets = [];
  double rotationX = 0.0;
  double rotationY = 0.0;
  int _moveCount = 0;
  bool _isSolved = false;

  int get moveCount => _moveCount;
  bool get isSolved => _isSolved;

  RubikCubeModel() {
    _initializeCube();
  }

  void _initializeCube() {
    cubelets = List.generate(
      3,
      (x) => List.generate(
        3,
        (y) => List.generate(3, (z) => Cubelet(x: x, y: y, z: z)),
      ),
    );
    _assignColors();
  }

  void _assignColors() {
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        for (int z = 0; z < 3; z++) {
          final cubelet = cubelets[x][y][z];
          if (x == 0) cubelet.setFaceColor('left', CubeColor.orange);
          if (x == 2) cubelet.setFaceColor('right', CubeColor.red);
          if (y == 0) cubelet.setFaceColor('down', CubeColor.yellow);
          if (y == 2) cubelet.setFaceColor('up', CubeColor.white);
          if (z == 0) cubelet.setFaceColor('back', CubeColor.green);
          if (z == 2) cubelet.setFaceColor('front', CubeColor.blue);
        }
      }
    }
    _isSolved = true;
    notifyListeners();
  }

  void rotateCube(double deltaX, double deltaY) {
    rotationX += deltaY * 0.01;
    rotationY += deltaX * 0.01;
    notifyListeners();
  }

  void rotateFace(String face, bool clockwise) {
    _moveCount++;
    _isSolved = false;

    switch (face) {
      case 'front':
        _rotateFrontFace(clockwise);
        break;
      case 'back':
        _rotateBackFace(clockwise);
        break;
      case 'left':
        _rotateLeftFace(clockwise);
        break;
      case 'right':
        _rotateRightFace(clockwise);
        break;
      case 'up':
        _rotateUpFace(clockwise);
        break;
      case 'down':
        _rotateDownFace(clockwise);
        break;
      case 'middle_x': // M - Middle layer along X axis
        _rotateMiddleX(clockwise);
        break;
      case 'middle_y': // E - Middle layer along Y axis
        _rotateMiddleY(clockwise);
        break;
      case 'middle_z': // S - Middle layer along Z axis
        _rotateMiddleZ(clockwise);
        break;
    }

    _isSolved = checkSolved();
    notifyListeners();
  }

  void _rotateFrontFace(bool clockwise) {
    List<List<Cubelet>> frontLayer = [];
    for (int x = 0; x < 3; x++) {
      frontLayer.add([]);
      for (int y = 0; y < 3; y++) {
        frontLayer[x].add(cubelets[x][y][2]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (clockwise) {
          cubelets[x][y][2] = frontLayer[2 - y][x];
          _rotateCubeletFaces(cubelets[x][y][2], 'z', true);
        } else {
          cubelets[x][y][2] = frontLayer[y][2 - x];
          _rotateCubeletFaces(cubelets[x][y][2], 'z', false);
        }
      }
    }
  }

  void _rotateBackFace(bool clockwise) {
    List<List<Cubelet>> backLayer = [];
    for (int x = 0; x < 3; x++) {
      backLayer.add([]);
      for (int y = 0; y < 3; y++) {
        backLayer[x].add(cubelets[x][y][0]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (clockwise) {
          cubelets[x][y][0] = backLayer[y][2 - x];
          _rotateCubeletFaces(cubelets[x][y][0], 'z', false);
        } else {
          cubelets[x][y][0] = backLayer[2 - y][x];
          _rotateCubeletFaces(cubelets[x][y][0], 'z', true);
        }
      }
    }
  }

  void _rotateLeftFace(bool clockwise) {
    // Tạo bản sao của layer để tránh ghi đè
    List<List<Cubelet>> leftLayer = [];
    for (int y = 0; y < 3; y++) {
      leftLayer.add([]);
      for (int z = 0; z < 3; z++) {
        leftLayer[y].add(cubelets[0][y][z]);
      }
    }

    // L xoay ngược chiều với R (theo chuẩn Rubik)
    // Theo công thức: newGridPos = [x, 2-z, y] khi clockwise = false (L)
    // Cubelet ở [0][y][z] sẽ di chuyển đến [0][2-z][y]
    for (int y = 0; y < 3; y++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          // L clockwise = xoay ngược chiều kim đồng hồ = clockwise = false trong công thức
          // [0][y][z] -> [0][2-z][y]
          cubelets[0][2 - z][y] = leftLayer[y][z];
          _rotateCubeletFaces(cubelets[0][2 - z][y], 'x', false);
        } else {
          // L' counter-clockwise = xoay theo chiều kim đồng hồ = clockwise = true trong công thức
          // [0][y][z] -> [0][z][2-y]
          cubelets[0][z][2 - y] = leftLayer[y][z];
          _rotateCubeletFaces(cubelets[0][z][2 - y], 'x', true);
        }
      }
    }
  }

  void _rotateRightFace(bool clockwise) {
    // Tạo bản sao của layer để tránh ghi đè
    List<List<Cubelet>> rightLayer = [];
    for (int y = 0; y < 3; y++) {
      rightLayer.add([]);
      for (int z = 0; z < 3; z++) {
        rightLayer[y].add(cubelets[2][y][z]);
      }
    }

    // Theo công thức: newGridPos = [x, z, 2 - y] khi clockwise = true
    // Cubelet ở [2][y][z] sẽ di chuyển đến [2][z][2-y]
    for (int y = 0; y < 3; y++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          // [2][y][z] -> [2][z][2-y]
          cubelets[2][z][2 - y] = rightLayer[y][z];
          _rotateCubeletFaces(cubelets[2][z][2 - y], 'x', true);
        } else {
          // [2][y][z] -> [2][2-z][y]
          cubelets[2][2 - z][y] = rightLayer[y][z];
          _rotateCubeletFaces(cubelets[2][2 - z][y], 'x', false);
        }
      }
    }
  }

  void _rotateUpFace(bool clockwise) {
    List<List<Cubelet>> upLayer = [];
    for (int x = 0; x < 3; x++) {
      upLayer.add([]);
      for (int z = 0; z < 3; z++) {
        upLayer[x].add(cubelets[x][2][z]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          cubelets[x][2][z] = upLayer[2 - z][x];
          _rotateCubeletFaces(cubelets[x][2][z], 'y', false);
        } else {
          cubelets[x][2][z] = upLayer[z][2 - x];
          _rotateCubeletFaces(cubelets[x][2][z], 'y', true);
        }
      }
    }
  }

  void _rotateDownFace(bool clockwise) {
    List<List<Cubelet>> downLayer = [];
    for (int x = 0; x < 3; x++) {
      downLayer.add([]);
      for (int z = 0; z < 3; z++) {
        downLayer[x].add(cubelets[x][0][z]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          cubelets[x][0][z] = downLayer[z][2 - x];
          _rotateCubeletFaces(cubelets[x][0][z], 'y', true);
        } else {
          cubelets[x][0][z] = downLayer[2 - z][x];
          _rotateCubeletFaces(cubelets[x][0][z], 'y', false);
        }
      }
    }
  }

  // M - Middle layer along X axis (between left and right)
  // M xoay theo hướng L (ngược với R)
  void _rotateMiddleX(bool clockwise) {
    // Tạo bản sao của layer để tránh ghi đè
    List<List<Cubelet>> middleLayer = [];
    for (int y = 0; y < 3; y++) {
      middleLayer.add([]);
      for (int z = 0; z < 3; z++) {
        middleLayer[y].add(cubelets[1][y][z]);
      }
    }

    // M xoay theo hướng L (ngược với R)
    // Theo công thức: newGridPos = [x, 2-z, y] khi clockwise = false (M)
    for (int y = 0; y < 3; y++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          // M clockwise = xoay ngược chiều kim đồng hồ (theo hướng L)
          // [1][y][z] -> [1][2-z][y]
          cubelets[1][2 - z][y] = middleLayer[y][z];
          _rotateCubeletFaces(cubelets[1][2 - z][y], 'x', false);
        } else {
          // M' counter-clockwise = xoay theo chiều kim đồng hồ
          // [1][y][z] -> [1][z][2-y]
          cubelets[1][z][2 - y] = middleLayer[y][z];
          _rotateCubeletFaces(cubelets[1][z][2 - y], 'x', true);
        }
      }
    }
  }

  // E - Middle layer along Y axis (between up and down)
  void _rotateMiddleY(bool clockwise) {
    List<List<Cubelet>> middleLayer = [];
    for (int x = 0; x < 3; x++) {
      middleLayer.add([]);
      for (int z = 0; z < 3; z++) {
        middleLayer[x].add(cubelets[x][1][z]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int z = 0; z < 3; z++) {
        if (clockwise) {
          cubelets[x][1][z] = middleLayer[2 - z][x];
          _rotateCubeletFaces(cubelets[x][1][z], 'y', false);
        } else {
          cubelets[x][1][z] = middleLayer[z][2 - x];
          _rotateCubeletFaces(cubelets[x][1][z], 'y', true);
        }
      }
    }
  }

  // S - Middle layer along Z axis (between front and back)
  void _rotateMiddleZ(bool clockwise) {
    List<List<Cubelet>> middleLayer = [];
    for (int x = 0; x < 3; x++) {
      middleLayer.add([]);
      for (int y = 0; y < 3; y++) {
        middleLayer[x].add(cubelets[x][y][1]);
      }
    }

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (clockwise) {
          cubelets[x][y][1] = middleLayer[2 - y][x];
          _rotateCubeletFaces(cubelets[x][y][1], 'z', true);
        } else {
          cubelets[x][y][1] = middleLayer[y][2 - x];
          _rotateCubeletFaces(cubelets[x][y][1], 'z', false);
        }
      }
    }
  }

  // Xoay màu sắc các mặt của cubelet khi cubelet bị xoay
  // axis: 'x', 'y', hoặc 'z'
  // clockwise: true nếu xoay theo chiều kim đồng hồ
  void _rotateCubeletFaces(Cubelet cubelet, String axis, bool clockwise) {
    // Lưu tất cả các mặt (kể cả null) để không mất thông tin
    final oldFaces = <String, CubeColor?>{};
    final allFaces = ['front', 'back', 'up', 'down', 'right', 'left'];
    for (final face in allFaces) {
      oldFaces[face] = cubelet.getFaceColor(face);
    }
    
    final newFaces = <String, CubeColor?>{};

    if (axis == 'x') {
      // Xoay quanh trục X: front->top->back->bottom->front
      // (nhìn từ phía dương X - right side)
      if (clockwise) {
        newFaces['front'] = oldFaces['down'];
        newFaces['back'] = oldFaces['up'];
        newFaces['up'] = oldFaces['front'];
        newFaces['down'] = oldFaces['back'];
        newFaces['right'] = oldFaces['right'];
        newFaces['left'] = oldFaces['left'];
      } else {
        newFaces['front'] = oldFaces['up'];
        newFaces['back'] = oldFaces['down'];
        newFaces['up'] = oldFaces['back'];
        newFaces['down'] = oldFaces['front'];
        newFaces['right'] = oldFaces['right'];
        newFaces['left'] = oldFaces['left'];
      }
    } else if (axis == 'y') {
      // Xoay quanh trục Y: front->left->back->right->front
      if (clockwise) {
        newFaces['front'] = oldFaces['right'];
        newFaces['back'] = oldFaces['left'];
        newFaces['right'] = oldFaces['back'];
        newFaces['left'] = oldFaces['front'];
        newFaces['up'] = oldFaces['up'];
        newFaces['down'] = oldFaces['down'];
      } else {
        newFaces['front'] = oldFaces['left'];
        newFaces['back'] = oldFaces['right'];
        newFaces['right'] = oldFaces['front'];
        newFaces['left'] = oldFaces['back'];
        newFaces['up'] = oldFaces['up'];
        newFaces['down'] = oldFaces['down'];
      }
    } else if (axis == 'z') {
      // Xoay quanh trục Z: top->right->bottom->left->top
      if (clockwise) {
        newFaces['up'] = oldFaces['left'];
        newFaces['down'] = oldFaces['right'];
        newFaces['right'] = oldFaces['up'];
        newFaces['left'] = oldFaces['down'];
        newFaces['front'] = oldFaces['front'];
        newFaces['back'] = oldFaces['back'];
      } else {
        newFaces['up'] = oldFaces['right'];
        newFaces['down'] = oldFaces['left'];
        newFaces['right'] = oldFaces['down'];
        newFaces['left'] = oldFaces['up'];
        newFaces['front'] = oldFaces['front'];
        newFaces['back'] = oldFaces['back'];
      }
    }

    // Cập nhật màu sắc, giữ lại tất cả các mặt (kể cả null)
    cubelet.faces.clear();
    newFaces.forEach((face, color) {
      if (color != null) {
        cubelet.setFaceColor(face, color);
      }
      // Nếu color là null, không set gì cả (mặt đó không có màu)
    });
  }

  void shuffle({int moves = 20}) {
    final faces = ['front', 'back', 'left', 'right', 'up', 'down'];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < moves; i++) {
      final face = faces[random % faces.length];
      final clockwise = (random + i) % 2 == 0;
      rotateFace(face, clockwise);
    }
    _moveCount = 0;
    _isSolved = false;
    notifyListeners();
  }

  void reset() {
    rotationX = 0.0;
    rotationY = 0.0;
    _moveCount = 0;
    _isSolved = false;
    _initializeCube();
    notifyListeners();
  }

  bool checkSolved() {
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        for (int z = 0; z < 3; z++) {
          final cubelet = cubelets[x][y][z];
          if (x == 0 && cubelet.getFaceColor('left') != CubeColor.orange) {
            return false;
          }
          if (x == 2 && cubelet.getFaceColor('right') != CubeColor.red) {
            return false;
          }
          if (y == 0 && cubelet.getFaceColor('down') != CubeColor.yellow) {
            return false;
          }
          if (y == 2 && cubelet.getFaceColor('up') != CubeColor.white) {
            return false;
          }
          if (z == 0 && cubelet.getFaceColor('back') != CubeColor.green) {
            return false;
          }
          if (z == 2 && cubelet.getFaceColor('front') != CubeColor.blue) {
            return false;
          }
        }
      }
    }
    return true;
  }
}

