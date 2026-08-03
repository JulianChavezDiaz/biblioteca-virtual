import 'package:flutter/material.dart';

class LazyTabView extends StatefulWidget {
  final List<Widget> tabs;
  final TabController controller;

  const LazyTabView({
    super.key,
    required this.tabs,
    required this.controller,
  });

  @override
  State<LazyTabView> createState() => _LazyTabViewState();
}

class _LazyTabViewState extends State<LazyTabView> {
  final Set<int> _loadedTabs = {0};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (widget.controller.indexIsChanging) {
      setState(() {
        _loadedTabs.add(widget.controller.index);
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: List.generate(widget.tabs.length, (index) {
        if (_loadedTabs.contains(index)) {
          return widget.tabs[index];
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
