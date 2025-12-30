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
        appBar: AppBar(
            title: Text(_viewModel.trainingId),
            centerTitle: true),
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
            child: Padding(padding: EdgeInsets.all(32), child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [
                  Row(spacing: 16, children: [Text('Base models', style: TextTheme.of(context).bodyLarge), Text(_viewModel.trainingData.baseModel)]),
                  Row(spacing: 16, children: [Text('Utterances   ', style: TextTheme.of(context).bodyLarge), Text('${_viewModel.trainingData.trainingExamples}')]),
                  Row(spacing: 16, children: [Text('Language     ', style: TextTheme.of(context).bodyLarge), Text('${_viewModel.trainingData.language}')]),
                  Row(spacing: 16, children: [Text('WER             ', style: TextTheme.of(context).bodyLarge), Text('${_viewModel.trainingData.wordErrorRate.toStringAsFixed(2)}')]),
                    ])))));
  }
}
