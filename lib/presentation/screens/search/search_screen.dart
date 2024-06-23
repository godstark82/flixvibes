import 'package:dooflix/features/anime/presentation/widgets/anime_card.dart';
import 'package:dooflix/logic/blocs/search_bloc/search_bloc.dart';
import 'package:dooflix/presentation/pages/search_result_page.dart';
import 'package:dooflix/presentation/widgets/heading_widget.dart';
import 'package:dooflix/presentation/widgets/movie_card.dart';
import 'package:dooflix/presentation/widgets/my_snack.dart';
import 'package:dooflix/presentation/widgets/tv_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? query;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: TextFormField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              suffix: IconButton(
                  onPressed: () {
                    if (query != null && query!.isNotEmpty) {
                      Get.to(() => SearchResultPage(query: query ?? ""));
                    } else {
                      MySnackBar.showredSnackBar(context,
                          message: 'Please Enter a Query');
                    }
                  },
                  icon: Icon(Icons.search))),
          onChanged: (value) {
            // Perform search functionality here
            query = value;
            context.read<SearchBloc>().add(InitiateSearchEvent(value));
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is LoadingSearchState) {
           
            return Center(child: CircularProgressIndicator());
          }
          if (state is LoadedSearchState) {
            
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              if(state.fetchedMovies.isNotEmpty) SliverToBoxAdapter(child: HeadingWidget(text: 'Movies')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 225,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.fetchedMovies.length,
                    itemBuilder: (context, index) {
                      return MovieCard(movie: state.fetchedMovies[index]);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              if(state.fetchedTv.isNotEmpty) SliverToBoxAdapter(child: HeadingWidget(text: 'Series')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 225,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.fetchedTv.length,
                    itemBuilder: (context, index) {
                      return TvCard(tv: state.fetchedTv[index]);
                    },
                  ),
                ),
              ),
               SliverToBoxAdapter(child: SizedBox(height: 12)),
              if(state.fetchedAnimes.isNotEmpty) SliverToBoxAdapter(child: HeadingWidget(text: 'Anime')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 225,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.fetchedAnimes.length,
                    itemBuilder: (context, index) {
                      return AnimeCard(anime: state.fetchedAnimes[index]);
                    },
                  ),
                ),
              ),
            ]);
          }
          if (state is ErrorSearchState) {
            return Center(child: Text('Error'));
          }

          return Center(
            child: Text('Search results will appear here'),
          );
        },
      ),
    );
  }
}
