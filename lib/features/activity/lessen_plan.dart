
import 'package:flutter/material.dart';

import '../../resorces/pallete.dart';
import 'lessen_list.dart';

class LessenPlanScreen extends StatelessWidget {

  const LessenPlanScreen({super.key,});

  @override
  Widget build(BuildContext context) {

    return _LessenPlanScreenView();

  }
}

class _LessenPlanScreenView extends StatefulWidget {

  const _LessenPlanScreenView();

  @override
  State<_LessenPlanScreenView> createState() => _LessenPlanScreenViewState();
}

class _LessenPlanScreenViewState extends State<_LessenPlanScreenView> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9DFFF), Color(0xFFF3EFFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lessen Plan', style: TextStyle(color: Colors.black)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('New Lessen',style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Palette.textForeground),),
                  ),
                )
              ],
            ),
          ),
          body: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in All lessens...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.search),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {

                      },
                    ),
                  ),
                ),
                // Media Grid
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child:  const Expanded(child: LessenList())
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
