import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/navigation.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/presentation/widgets/transaction_list_item.dart';

/// Off in widget tests, which can't load map tiles from the network.
final mapTilesEnabledProvider = Provider<bool>((ref) => true);

/// The report's "Map" tab: transactions that have a location, as pins
/// colored by category and sized by amount.
class SpendingMapView extends ConsumerStatefulWidget {
  final List<MoneyTransaction> transactions;

  const SpendingMapView({super.key, required this.transactions});

  @override
  ConsumerState<SpendingMapView> createState() => _SpendingMapViewState();
}

class _SpendingMapViewState extends ConsumerState<SpendingMapView> {
  MoneyTransaction? _picked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final located = widget.transactions
        .where((t) => t.hasLocation && t.type != TransactionType.transfer)
        .toList();
    final counted = widget.transactions
        .where((t) => t.type != TransactionType.transfer)
        .length;

    final children = <Widget>[];
    if (located.isEmpty) {
      children.add(
        EmptyStateView(
          icon: Icons.map_outlined,
          title: l10n.mapNoLocations,
          message: l10n.mapNoLocationsMessage,
        ),
      );
    } else {
      final peak = located.fold<int>(
        0,
        (m, t) => t.amountMinor > m ? t.amountMinor : m,
      );
      final points = [
        for (final t in located) LatLng(t.latitude!, t.longitude!),
      ];
      final dark = theme.brightness == Brightness.dark;
      children.addAll([
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: SizedBox(
            height: 380,
            child: FlutterMap(
              // A new set of points (period or account change) refits.
              key: ValueKey(Object.hashAll(located.map((t) => t.id))),
              options: MapOptions(
                initialCameraFit: points.length == 1
                    ? null
                    : CameraFit.coordinates(
                        coordinates: points,
                        padding: const EdgeInsets.all(40),
                        maxZoom: 16,
                      ),
                initialCenter: points.first,
                initialZoom: 15,
                backgroundColor: colors.elevatedSurface,
                onTap: (_, _) => setState(() => _picked = null),
              ),
              children: [
                if (ref.watch(mapTilesEnabledProvider))
                  // Esri canvas basemaps: keyless, browser-friendly, with a
                  // real dark style (tile.openstreetmap.org can be blocked).
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/'
                        'Canvas/World_${dark ? 'Dark' : 'Light'}_Gray_Base/'
                        'MapServer/tile/{z}/{y}/{x}',
                    maxNativeZoom: 16,
                    userAgentPackageName: 'com.thdevfe.moneytracker',
                  ),
                MarkerLayer(
                  markers: [
                    for (final t in located)
                      Marker(
                        point: LatLng(t.latitude!, t.longitude!),
                        width: 44,
                        height: 44,
                        child: _Pin(
                          key: ValueKey('pin_${t.id}'),
                          transaction: t,
                          // 24–44 px by amount.
                          size: 24 + 20 * (t.amountMinor / peak),
                          selected: _picked?.id == t.id,
                          onTap: () => setState(() => _picked = t),
                        ),
                      ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('Esri, HERE, Garmin, OpenStreetMap'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.mapLocatedCount(located.length, counted),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (_picked != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Card(
            clipBehavior: Clip.antiAlias,
            child: TransactionListItem(
              transaction: _picked!,
              onTap: () => openEditTransaction(context, _picked!),
            ),
          ),
        ],
      ]);
    }
    children.addAll([
      const SizedBox(height: AppSpacing.md),
      const SaveLocationSwitch(),
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _Pin extends StatelessWidget {
  final MoneyTransaction transaction;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _Pin({
    super.key,
    required this.transaction,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = transaction.category;
    final tint = category?.tint ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? size + 6 : size,
          height: selected ? size + 6 : size,
          decoration: BoxDecoration(
            color: tint,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: selected ? 3 : 2),
            boxShadow: const [
              BoxShadow(color: Color(0x55000000), blurRadius: 6),
            ],
          ),
          child: Icon(
            category?.icon ?? Icons.place_rounded,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// "Save location when adding" switch; asks for permission when turned on.
class SaveLocationSwitch extends ConsumerWidget {
  const SaveLocationSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: SwitchListTile(
        key: const ValueKey('save_location'),
        secondary: const Icon(Icons.my_location_rounded),
        title: Text(l10n.saveLocation),
        subtitle: Text(l10n.saveLocationHint),
        value: ref.watch(saveLocationProvider),
        onChanged: (on) => setSaveLocation(context, ref, on),
      ),
    );
  }
}

/// Turns location saving on or off. Turning it on asks for permission now,
/// so the first entry doesn't wait on a prompt.
Future<void> setSaveLocation(
  BuildContext context,
  WidgetRef ref,
  bool on,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  ref.read(saveLocationProvider.notifier).set(on);
  if (!on) return;
  final place = await ref.read(locationServiceProvider).current();
  if (place == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.locationUnavailable)));
  }
}
