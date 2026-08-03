import 'package:flutter/material.dart';

class OptimizedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final int itemsPerPage;
  final ScrollController? scrollController;

  const OptimizedListView({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.itemsPerPage = 20,
    this.scrollController,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final newItems = await widget.loadData(_currentPage, widget.itemsPerPage);
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length == widget.itemsPerPage;
        _currentPage++;
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.loadData(_currentPage, widget.itemsPerPage);
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length == widget.itemsPerPage;
        _currentPage++;
      });
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ??
          const Center(child: Text('No hay elementos'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}
