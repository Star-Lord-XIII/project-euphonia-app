import 'package:flutter/material.dart';

import '../viewmodel/train_mode_viewmodel.dart';

class TrainModeView extends StatefulWidget {
  final TrainModeViewModel viewModel;

  const TrainModeView({super.key, required this.viewModel});

  @override
  State<TrainModeView> createState() => _TrainModeViewState();
}

class _TrainModeViewState extends State<TrainModeView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16.0,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                        child: MaterialButton(
                      onPressed: widget.viewModel.training
                          ? null
                          : () => widget.viewModel.train.execute(),
                      color: Colors.blue,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(80)),
                      ),
                      padding: const EdgeInsets.fromLTRB(80, 24, 80, 24),
                      child: Text(
                        widget.viewModel.training ? 'Training...' : 'Train',
                        style: const TextStyle(fontSize: 24),
                      ),
                    )),
                    Expanded(
                        child: Text(widget.viewModel.progressStatus,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            softWrap: true))
                  ]));
        });
  }
}
