import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lapor_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<Widget> _screens = [
    HomeScreen(),
    LaporScreen(),
    ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.add_circle_rounded,
    Icons.person_rounded,
  ];

  final List<IconData> _outlineIcons = [
    Icons.home_outlined,
    Icons.add_circle_outline,
    Icons.person_outline,
  ];

  final List<String> _labels = ['Home', 'Lapor', 'Profile'];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300), // Reduced duration
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Changed to simpler curve
    ));

    _animationController.forward();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _slideAnimation.value)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              height: 70, // Slightly reduced height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated background indicator - SMALLER SIZE
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200), // Much faster
                    curve: Curves.easeOut, // Smoother curve
                    left: _getIndicatorPosition(),
                    top: 12, // Adjusted position
                    child: Container(
                      width: 46, // Much smaller - was 60
                      height: 46, // Much smaller - was 60
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF9800),
                            Color(0xFFFFB74D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(23), // Half of width/height
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF9800).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Navigation items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return _buildNavItem(index);
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getIndicatorPosition() {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth - 40; // margin 20 on each side
    double itemWidth = containerWidth / 3;
    return (_selectedIndex * itemWidth) + (itemWidth - 46) / 2; // Updated for new circle size
  }

  Widget _buildNavItem(int index) {
    bool isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with faster animation
              AnimatedContainer(
                duration: Duration(milliseconds: 150), // Faster response
                curve: Curves.easeOut,
                padding: EdgeInsets.all(6),
                child: Icon(
                  isSelected ? _icons[index] : _outlineIcons[index],
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                  size: isSelected ? 26 : 22, // Slightly smaller
                ),
              ),
              
              // Label with faster fade
              AnimatedOpacity(
                duration: Duration(milliseconds: 150), // Faster
                opacity: isSelected ? 0.0 : 1.0,
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
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