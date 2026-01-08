import 'package:flutter/material.dart';
import 'package:teacher_app/core/pallete.dart';
import 'package:teacher_app/features/messages/select_childs_screen.dart';

class HistoryMealScreen extends StatelessWidget {
  final String activityType;
  final String? classId;

  const HistoryMealScreen({
    super.key,
    required this.activityType,
    this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return _LessenPlanScreenView(activityType: activityType, classId: classId);
  }
}

class _LessenPlanScreenView extends StatefulWidget {
  final String activityType;
  final String? classId;

  const _LessenPlanScreenView({required this.activityType, this.classId});

  @override
  State<_LessenPlanScreenView> createState() => _LessenPlanScreenViewState();
}

class _LessenPlanScreenViewState extends State<_LessenPlanScreenView> {
  void _navigateToAddNew(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: widget.classId,
          activityType: widget.activityType,
        ),
      ),
    );
  }

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
                Text(
                  'History-${widget.activityType[0].toUpperCase()}${widget.activityType.substring(1)}',
                  style: const TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () => _navigateToAddNew(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Add New',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Palette.textForeground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Child...',
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
                    onChanged: (value) {},
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History Archive',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Palette.textForeground,
                                ),
                              ),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Palette.textForeground,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return HistoryMealCard(
                                name: 'Olivia Carter',
                                date: 'July 16',
                                type: 'Lunch',
                                quantity: 'All',
                                imageUrl: 'https://i.pravatar.cc/150?img=3',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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

class HistoryMealCard extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String quantity;
  final String imageUrl;

  const HistoryMealCard({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    required this.quantity,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Palette.textForeground,
                  ),
                ),
              ),

              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Palette.textForeground,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              _InfoText(label: 'Type', value: type),
              const SizedBox(width: 24),
              _InfoText(label: 'Quantity', value: quantity),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Palette.txtPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
