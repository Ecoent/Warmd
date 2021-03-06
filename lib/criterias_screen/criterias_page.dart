import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/common.dart';
import '../common/criterias.dart';
import '../common/warmd_icons_icons.dart';
import '../details_screen/details_screen.dart';
import '../generated/i18n.dart';
import 'earth_anim_controller.dart';

class CriteriasPage extends StatelessWidget {
  final String title;

  CriteriasPage({this.title, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<EarthAnimController>(
      create: (context) => EarthAnimController(),
      child: Consumer<EarthAnimController>(
        builder: (context, animController, child) {
          var state = Provider.of<CriteriasState>(context);
          animController.score = state.categorySet.co2EqTonsPerYear().toInt();

          return _buildContent(context, animController, state);
        },
      ),
    );
  }

  Scaffold _buildContent(BuildContext context, EarthAnimController animController, CriteriasState state) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, animController, state),
            Expanded(
              child: ListView(
                  key: ValueKey(state.categorySet),
                  padding: const EdgeInsets.all(8.0),
                  scrollDirection: Axis.vertical,
                  children: [
                    if (state.categorySet is GlobalCategorySet) _buildGlobalExplanation(context),
                    ..._buildCategories(context, state),
                    if (!(state.categorySet is GlobalCategorySet))
                      Padding(
                        padding: const EdgeInsets.only(left: 64, right: 64, bottom: 32),
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetailsScreen(state)),
                            );
                          },
                          child: Text(S.of(context).seeResults),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                      )
                  ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          state.categorySet = index == 0 ? IndividualCategorySet(context) : GlobalCategorySet(context);
        },
        currentIndex: state.categorySet is IndividualCategorySet ? 0 : 1,
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blueGrey[200],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(WarmdIcons.human_male),
            title: Text(S.of(context).individualApproach),
          ),
          BottomNavigationBarItem(
            icon: const Icon(WarmdIcons.earth),
            title: Text(S.of(context).globalApproach),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalExplanation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.grey[300],
              ),
              Gaps.w16,
              Expanded(
                child: Text(
                  S.of(context).globalImpactExplanation,
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EarthAnimController animController, CriteriasState state) {
    String footprint = DetailsScreen.getFootprintValue(context, state);

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
      child: Column(
        children: [
          const Image(
            image: AssetImage("assets/text_logo_transparent_small.webp"),
            fit: BoxFit.contain,
            height: 70,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Container(
                      height: 128,
                      width: 128,
                      child: FlareActor(
                        "assets/global_warming.flr",
                        controller: animController,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).yourCarbonFootprint,
                      style: Theme.of(context).textTheme.title,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "$footprint",
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                    Gaps.h8,
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          S.of(context).knowMore,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailsScreen(state)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategories(BuildContext context, CriteriasState state) {
    return [
      for (CriteriaCategory cat in state.categorySet.categories)
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              children: [
                Image(
                  image: AssetImage("assets/${cat.key}.webp"),
                  fit: BoxFit.cover,
                  height: 164,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (Criteria crit in cat.criterias) ..._buildCriteria(context, state, crit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildCriteria(BuildContext context, CriteriasState state, Criteria c) {
    var unit = c.unit != null ? " " + c.unit : "";
    var valueWithUnit = NumberFormat.decimalPattern().format(c.currentValue.abs()).toString() + unit;

    return [
      Gaps.h32,
      Text(
        c.title,
        style: Theme.of(context).textTheme.subhead,
      ),
      if (c.labels != null) _buildDropdown(context, c, state) else _buildSlider(c, valueWithUnit, context, state),
      if (c.explanation != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildSmartText(context, c.explanation, FontWeight.normal, Colors.grey[400]),
        ),
    ];
  }

  Widget _buildDropdown(BuildContext context, Criteria c, CriteriasState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.blueGrey[700],
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: DropdownButton<int>(
            isExpanded: true,
            selectedItemBuilder: (BuildContext context) {
              return c.labels.map((String item) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ],
                );
              }).toList();
            },
            value: c.currentValue.toInt(),
            underline: Container(),
            onChanged: (int value) {
              c.currentValue = value.toDouble();
              state.persist(c);
            },
            items: c.labels
                .mapIndexed((index, label) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.body1.copyWith(color: _getDropdownTextColor(c, index)),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Color _getDropdownTextColor(Criteria c, int value) {
    if (c is UnitCriteria || c is MoneyChangeCriteria) return Colors.white;

    if (value == c.minValue) {
      return Colors.green[200];
    } else if (value == c.maxValue) {
      return Colors.orange[200];
    } else {
      return Colors.white;
    }
  }

  Widget _buildSlider(Criteria c, String valueWithUnit, BuildContext context, CriteriasState state) {
    return Row(
      children: [
        Icon(c.leftIcon),
        Expanded(
          child: Slider(
            min: c.minValue,
            max: c.maxValue,
            divisions: (c.maxValue - c.minValue) ~/ c.step,
            label: c.labels != null
                ? c.labels[c.currentValue.toInt()]
                : c.currentValue != c.maxValue || c is CleanElectricityCriteria
                    ? valueWithUnit
                    : S.of(context).valueWithMore(valueWithUnit),
            value: c.currentValue,
            onChanged: (double value) {
              c.currentValue = value;
              state.persist(c);
            },
          ),
        ),
        Icon(c.rightIcon),
      ],
    );
  }
}
