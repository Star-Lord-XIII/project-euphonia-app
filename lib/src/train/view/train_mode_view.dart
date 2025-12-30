import 'package:flutter/material.dart';

import '../../common/error_indicator.dart';
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
        listenable: widget.viewModel.initializeModel,
        builder: (context, child) {
          if (widget.viewModel.initializeModel.completed) {
            return child!;
          }
          return Column(
            children: [
              if (widget.viewModel.initializeModel.running)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (widget.viewModel.initializeModel.error)
                Expanded(
                  child: Center(
                    child: ErrorIndicator(
                      title: 'Unable to fetch data required for starting a training job',
                      label: 'Try again!',
                      onPressed: widget.viewModel.initializeModel.execute,
                    ),
                  ),
                ),
            ],
          );
        },
        child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              return Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.0,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25),
                        DropdownMenu(
                            label: Text('Language pack'),
                            dropdownMenuEntries:
                                widget.viewModel.languagePackSummary
                                    .map((x) => DropdownMenuEntry(
                                        value: x,
                                        label: x.name,
                                        trailingIcon: Wrap(
                                          children: [
                                            Chip(
                                                label: Text(x.language.codeShort
                                                    .toLowerCase()),
                                                labelPadding: EdgeInsets.zero,
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                visualDensity:
                                                    VisualDensity.compact)
                                          ],
                                        )))
                                    .toList(),
                            onSelected: (x) {
                              if (x != null) {
                                widget.viewModel
                                    .selectLanguagePackCode(x.languagePackCode);
                              }
                            }),
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
            }));
  }
}
