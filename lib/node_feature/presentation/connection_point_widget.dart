import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';

class ConnectionPointWidget extends StatelessWidget {
  final ConnectionPointModel connectionPoint;
  final NodeModel node;
  const ConnectionPointWidget(
      {super.key, required this.connectionPoint, required this.node});

  @override
  Widget build(BuildContext context) {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    
    return GestureDetector(
      onDoubleTap: () => connectionPoint.disconnect(),
      onPanStart: (details) {
        if(connectionPoint is InputConnectionPoint) return;
        log('point pan start');
        connectionProvider.startConnection(connectionPoint);
      },
      onPanUpdate: (details) {
        connectionProvider.updatePosition(details.globalPosition);
      },
      onPanEnd: (details) {
        connectionPoint.handlePanEndBehaviour(context);
      },
      child: Container(
        width: connectionPoint.width,
        height: connectionPoint.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: connectionPoint.color),
      ),
    );
  }
}
