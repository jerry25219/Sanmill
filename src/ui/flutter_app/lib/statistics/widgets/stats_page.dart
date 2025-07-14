




import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../custom_drawer/custom_drawer.dart';
import '../../generated/intl/l10n.dart';
import '../../shared/database/database.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/settings/settings.dart';
import '../../statistics/model/stats_settings.dart';
import '../services/stats_service.dart';


class StatisticsPage extends StatelessWidget {

  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      key: const Key('statistics_page_block_semantics'),
      child: Scaffold(
        key: const Key('statistics_page_scaffold'),
        appBar: AppBar(
          key: const Key('statistics_page_app_bar'),
          leading: CustomDrawerIcon.of(context)?.drawerIcon,
          title: Text(
            S.of(context).statistics,
            key: const Key('statistics_page_app_bar_title'),
            style: AppTheme.appBarTheme.titleTextStyle,
          ),
        ),

        body: ValueListenableBuilder<dynamic>(
          key: const Key('statistics_page_value_listenable_builder'),
          valueListenable: DB().listenStatsSettings,
          builder: (BuildContext context, _, __) {
            final StatsSettings settings = DB().statsSettings;
            return SettingsList(
              key: const Key('statistics_page_settings_list'),
              children: <Widget>[
                _buildHumanStatsCard(context, settings.humanStats),
                _buildAiDifficultyStatsCard(context, settings),
                _buildStatsSettingsCard(context, settings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsSettingsCard(BuildContext context, StatsSettings settings) {
    final S l10n = S.of(context);

    return SettingsCard(
      key: const Key('statistics_page_settings_card'),
      title: Text(
        l10n.settings,
        key: const Key('statistics_page_settings_card_title'),
      ),
      children: <Widget>[
        SettingsListTile.switchTile(
            key: const Key('statistics_page_enable_statistics_switch'),
            value: settings.isStatsEnabled,
            onChanged: (bool value) {
              DB().statsSettings = settings.copyWith(
                isStatsEnabled: value,
              );
            },
            titleString: S.of(context).enableStatistics,
            subtitleString: S.of(context).enableStatistics_Detail),


        ListTile(
          key: const Key('statistics_page_reset_statistics'),
          title: Text(
            S.of(context).resetStatistics,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          trailing: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.error,
          ),
          onTap: () => _showResetStatsConfirmationDialog(context),
        ),
      ],
    );
  }


  void _showResetStatsConfirmationDialog(BuildContext context) {
    final S l10n = S.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(S.of(context).resetStatistics),
          content: Text(S.of(context).thisWillResetAllGameStatistics),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                _resetStats();
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(S.of(context).ok),
            ),
          ],
        );
      },
    );
  }


  void _resetStats() {
    final StatsSettings statsSettings = DB().statsSettings;


    final PlayerStats resetHumanStats = PlayerStats(
      lastUpdated: DateTime.now(),

    );


    final StatsSettings newStatsSettings = statsSettings.copyWith(
      humanStats: resetHumanStats,

      aiDifficultyStatsMap: <int, PlayerStats>{},
    );


    DB().statsSettings = newStatsSettings;
  }

  Widget _buildHumanStatsCard(BuildContext context, PlayerStats humanStats) {
    final S l10n = S.of(context);
    final DateFormat dateFormat = DateFormat.yMd().add_Hm();
    final ThemeData theme = Theme.of(context);

    return SettingsCard(
      key: const Key('statistics_page_human_rating_card'),
      title: Text(
        l10n.myRating,
        key: const Key('statistics_page_human_rating_card_title'),
      ),
      children: <Widget>[

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              '${humanStats.rating}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _getRatingColor(context, humanStats.rating),
                  ),
            ),
          ),
        ),


        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[

              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                children: <Widget>[
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          l10n.wins,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          l10n.draws,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          l10n.losses,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              TableRow(
                children: <Widget>[
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          '${humanStats.wins}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          '${humanStats.draws}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          '${humanStats.losses}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),


        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[

              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                children: <Widget>[
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          S.of(context).winRate, // Win rate
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          S.of(context).drawRate, // Draw rate
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          S.of(context).lossRate, // Loss rate
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              TableRow(
                children: <Widget>[
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          humanStats.gamesPlayed > 0
                              ? '${(humanStats.wins / humanStats.gamesPlayed * 100).toStringAsFixed(1)}%'
                              : '0.0%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          humanStats.gamesPlayed > 0
                              ? '${(humanStats.draws / humanStats.gamesPlayed * 100).toStringAsFixed(1)}%'
                              : '0.0%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          humanStats.gamesPlayed > 0
                              ? '${(humanStats.losses / humanStats.gamesPlayed * 100).toStringAsFixed(1)}%'
                              : '0.0%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),


        Column(
          children: <Widget>[
            ListTile(
              title: Text(l10n.gamesPlayed),
              trailing: Text(
                humanStats.gamesPlayed.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.lastUpdated),
              trailing: Text(
                humanStats.lastUpdated != null
                    ? dateFormat.format(humanStats.lastUpdated!)
                    : "-",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiDifficultyStatsCard(
      BuildContext context, StatsSettings settings) {
    final S l10n = S.of(context);
    final ThemeData theme = Theme.of(context);


    const TextStyle monoStyle = TextStyle(
      fontFamily: 'monospace',
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    );

    return SettingsCard(
      key: const Key('statistics_page_ai_statistics_card'),
      title: Text(
        S.of(context).aiStatistics,
        key: const Key('statistics_page_ai_statistics_card_title'),
      ),
      children: <Widget>[

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const <DataColumn>[
              DataColumn(
                label: Center(child: Text('🎚️')), // Difficulty Level
                numeric: true,
              ),
              DataColumn(
                label: Center(child: Text('⭐')), // Rating
                numeric: true,
              ),
              DataColumn(label: Center(child: Text('🔢'))), // Total
              DataColumn(
                  label: Center(child: Text('⚪'))), // White (Human perspective)
              DataColumn(
                  label: Center(child: Text('⚫'))), // Black (Human perspective)
            ],
            rows: List<DataRow>.generate(
              30, // Display levels 1-30
              (int index) {
                final int level = index + 1;

                final PlayerStats aiLvlStats =
                    settings.getAiDifficultyStats(level);


                final int fixedAiEloRating =
                    EloRatingService.getFixedAiEloRating(level);


                final String totalStats =
                    '${aiLvlStats.losses}/${aiLvlStats.draws}/${aiLvlStats.wins}';


                final String whiteStats = aiLvlStats.blackGamesPlayed > 0
                    ? '${aiLvlStats.blackLosses}/${aiLvlStats.blackDraws}/${aiLvlStats.blackWins}'
                    : '0/0/0';


                final String blackStats = aiLvlStats.whiteGamesPlayed > 0
                    ? '${aiLvlStats.whiteLosses}/${aiLvlStats.whiteDraws}/${aiLvlStats.whiteWins}'
                    : '0/0/0';

                return DataRow(
                  cells: <DataCell>[

                    DataCell(Text(
                      '$level',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),

                    DataCell(Text(
                      '$fixedAiEloRating', // Display the fixed ELO rating
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(context,
                            fixedAiEloRating), // Color based on fixed ELO
                      ),
                    )),

                    DataCell(Text(
                      totalStats,
                      style: monoStyle,
                    )),

                    DataCell(Text(
                      whiteStats,
                      style: monoStyle,
                    )),

                    DataCell(Text(
                      blackStats,
                      style: monoStyle,
                    )),
                  ],
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${S.of(context).format} W/D/L (${l10n.wins}/${l10n.draws}/${l10n.losses})',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(BuildContext context, int rating) {
    if (rating >= 2000) {
      return Colors.purple;
    } else if (rating >= 1800) {
      return Colors.blue;
    } else if (rating >= 1600) {
      return Colors.green;
    } else if (rating >= 1400) {
      return Colors.amber;
    } else if (rating >= 1200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
