




import 'package:flutter/services.dart';

import '../../generated/assets/assets.gen.dart';


class GitInfo {

  const GitInfo({required this.branch, required this.revision});


  final String branch;


  final String? revision;
}


Future<GitInfo> get gitInfo async {
  final String branch = await rootBundle.loadString(Assets.files.gitBranch);
  final String revision = await rootBundle.loadString(Assets.files.gitRevision);

  return GitInfo(branch: branch, revision: revision);
}
