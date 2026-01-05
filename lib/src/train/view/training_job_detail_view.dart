import 'package:flutter/material.dart';

import '../../common/error_indicator.dart';
import '../viewmodel/training_job_detail_viewmodel.dart';

class TrainingJobDetailView extends StatelessWidget {
  final TrainingJobDetailViewModel _viewModel;

  const TrainingJobDetailView(
      {super.key, required TrainingJobDetailViewModel viewModel})
      : _viewModel = viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_viewModel.trainingId), centerTitle: true),
        body: ListenableBuilder(
            listenable: _viewModel.initializeModel,
            builder: (context, child) {
              if (_viewModel.initializeModel.completed) {
                return child!;
              }
              return Column(
                children: [
                  if (_viewModel.initializeModel.running)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_viewModel.initializeModel.error)
                    Expanded(
                      child: Center(
                        child: ErrorIndicator(
                          title: 'Unable to fetch training job details',
                          label: 'Try again!',
                          onPressed: _viewModel.initializeModel.execute,
                        ),
                      ),
                    ),
                ],
              );
            },
            child: Padding(
                padding: EdgeInsets.all(32),
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16,
                            children: [
                              detailRow(context,
                                  label: 'Base model',
                                  value: _viewModel.trainingData.baseModel),
                              detailRow(context,
                                  label: 'Utterances',
                                  value:
                                      '${_viewModel.trainingData.trainingExamples}'),
                              detailRow(context,
                                  label: 'Language',
                                  value: _viewModel.trainingData.language),
                              detailRow(context,
                                  label: 'Final WER',
                                  value: _viewModel.trainingData.wordErrorRate
                                      .toStringAsFixed(2)),
                              detailRow(context,
                                  label: 'Baseline WER',
                                  value: _viewModel
                                      .trainingData.baselineModelWER
                                      .toStringAsFixed(2)),
                              detailRow(context,
                                  label: 'Splits',
                                  value:
                                      '(dev: ${_viewModel.trainingData.utterancesInDev}, train: ${_viewModel.trainingData.utterancesInTrain})'),
                            ])))));
  }

  Widget detailRow(BuildContext context,
      {required String label, required String value}) {
    return Row(spacing: 16, children: [
      SizedBox(
          width: 150,
          child: Text(label, style: TextTheme.of(context).bodyLarge)),
      Text(value)
    ]);
  }
}
