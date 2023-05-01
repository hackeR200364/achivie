import 'package:flutter/material.dart';

import '../styles.dart';

class DiscoverPageHeading extends StatelessWidget {
  const DiscoverPageHeading({
    super.key,
    required this.head,
  });

  final String head;

  @override
  Widget build(BuildContext context) {
    return Text(
      head,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
      ),
    );
  }
}

class ShowAllBtn extends StatelessWidget {
  const ShowAllBtn({
    super.key,
    required this.onTap,
    required this.head,
  });

  final VoidCallback onTap;
  final String head;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: AppColors.white.withOpacity(0.3),
              ),
              Center(
                child: Text(
                  head,
                  style: const TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
