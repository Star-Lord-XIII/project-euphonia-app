import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/error_indicator.dart';
import '../../service/model/training_job.dart';
import '../viewmodel/training_job_detail_viewmodel.dart';
import '../viewmodel/training_job_history_viewmodel.dart';
import 'training_job_detail_view.dart';

class TrainingJobHistoryView extends StatefulWidget {
  const TrainingJobHistoryView({super.key, required this.viewModel});

  final TrainingJobHistoryViewModel viewModel;

  @override
  State<TrainingJobHistoryView> createState() => _TrainingJobHistoryViewState();
}

class _TrainingJobHistoryViewState extends State<TrainingJobHistoryView> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final double verticalPadding = 32;
        return Scaffold(
          appBar:
              AppBar(title: Text('Training job history'), centerTitle: true),
          body: ListenableBuilder(
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
                          title: 'Unable to fetch training job history',
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
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: verticalPadding,
                        horizontal: 0,
                      ),
                      sliver: SliverList.list(
                        children: widget.viewModel.trainingJobs.map((job) {
                          final downloadProgress = widget.viewModel
                              .getModelDownloadProgress(job.trainingId);
                          final downloadStatus = widget.viewModel
                              .getModelDownloadStatus(job.trainingId);
                          return ListTile(
                              isThreeLine: true,
                              leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 16,
                                        height: 16,
                                        decoration: ShapeDecoration(
                                          shape: const CircleBorder(),
                                          color: _colorForTrainingJobProgress(
                                              job.progress),
                                        ))
                                  ]),
                              title: Row(spacing: 16.0, children: [
                                Text(job.trainingId.split('-').first),
                                Text(job.createdAt)
                              ]),
                              subtitle: Column(
                                  children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                  Text(job.progress),
                                                  SizedBox(width: 32),
                                                  Expanded(
                                                      child: Text(
                                                          job.subProgress ?? '',
                                                          maxLines: 3)),
                                                ].cast<Widget>() +
                                                (downloadStatus !=
                                                        DownloadStatus
                                                            .inProgress
                                                    ? []
                                                    : [
                                                        Text(downloadProgress !=
                                                                null
                                                            ? '(${(downloadProgress.downloaded / 1048576.0).toStringAsFixed(2)}/${(downloadProgress.total / 1048576.0).toStringAsFixed(2)} mb)'
                                                            : '')
                                                      ])),
                                      ].cast<Widget>() +
                                      (downloadStatus !=
                                              DownloadStatus.inProgress
                                          ? []
                                          : [
                                              SizedBox(height: 8),
                                              downloadProgress != null
                                                  ? LinearProgressIndicator(
                                                      value: ((downloadProgress
                                                                  .downloaded *
                                                              1.0) /
                                                          (downloadProgress
                                                                  .total *
                                                              1.0)),
                                                      color: Colors.blueAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2))
                                                  : Container()
                                            ])),
                              trailing: _trailingWidgetForListTile(
                                  job, downloadStatus),
                              onTap: _displayTrainingJobDetail(job.progress)
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TrainingJobDetailView(
                                                      viewModel:
                                                          TrainingJobDetailViewModel(
                                                              modelRepository:
                                                                  context
                                                                      .read(),
                                                              trainingId: job
                                                                  .trainingId))));
                                    }
                                  : null);
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _colorForTrainingJobProgress(String progress) {
    if (progress == 'submitted') {
      return Colors.blueAccent;
    } else if (progress == 'training') {
      return Colors.yellowAccent;
    } else if (progress == 'finished') {
      return Colors.greenAccent;
    }
    return Colors.redAccent;
  }

  bool _displayTrainingJobDetail(String progress) {
    return progress.toLowerCase() != 'failed';
  }

  Widget _trailingWidgetForListTile(TrainingJob job, DownloadStatus status) {
    Widget? trailingWidget;
    switch (status) {
      case DownloadStatus.notStarted:
        trailingWidget = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              MaterialButton(
                  onPressed: () {
                    widget.viewModel.downloadModel.execute(job.trainingId);
                  },
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                  child: Text('Download')),
              Icon(Icons.chevron_right)
            ]);
      case DownloadStatus.inProgress:
        trailingWidget = CircularProgressIndicator();
      case DownloadStatus.interrupted:
        trailingWidget = MaterialButton(
            onPressed: () {
              widget.viewModel.downloadModel.execute(job.trainingId);
            },
            color: Colors.redAccent,
            textColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(80)),
            ),
            child: Text('Try again!'));
      case DownloadStatus.completed:
        trailingWidget = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              Chip(label: Text('Available')),
              Icon(Icons.chevron_right)
            ]);
    }
    return Visibility(
        visible: job.progress == 'finished', child: trailingWidget);
  }
}
