import 'package:flutter/material.dart';

import '../../common/error_indicator.dart';
import '../viewmodel/training_job_history_viewmodel.dart';

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
                    SliverAppBar(
                      title: Text('Training job history'),
                      centerTitle: true,
                      pinned: true,
                    ),
                    SliverPadding(
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: verticalPadding,
                        horizontal: 0,
                      ),
                      sliver: SliverList.list(
                        children: widget.viewModel.trainingJobs
                            .map(
                              (job) => ListTile(
                                leading: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: ShapeDecoration(
                                      shape: const CircleBorder(),
                                      color: _colorForTrainingJobProgress(
                                          job.progress),
                                    )),
                                title: Text(job.trainingId),
                                subtitle: Row(children: [
                                  Text(job.progress),
                                  SizedBox(width: 32),
                                  Text(job.subProgress ?? '')
                                ]),
                                trailing: Visibility(
                                    visible: job.progress == 'finished',
                                    child: MaterialButton(
                                        onPressed: () {},
                                        color: Colors.blueAccent,
                                        textColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(80)),
                                        ),
                                        child: Text('Download'))),
                                onTap: () {},
                              ),
                            )
                            .toList(),
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
}
