import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';

class SearchDiscoverLoadingPage extends StatelessWidget {
  const SearchDiscoverLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopAppBar(
          hideBackButton: true,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          title: 'Search',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: DSDimens.sizeS,
          right: DSDimens.sizeS,
          bottom: DSDimens.sizeS,
        ),
        child: TextField(
          // controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for a cat food',
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
          ),
          // onChanged: (value) {
          //   _bloc.add(SearchQueryEvent(query: value));
          // },
        ),
      ),
    );
  }
}
