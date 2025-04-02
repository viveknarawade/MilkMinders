import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milk_minder/services/dairy_owner_session_data.dart';
import 'package:milk_minder/view/screens/auth/login_screen.dart';

class DairyOwnerProfilePage extends StatelessWidget {
  final Color primaryColor =
      const Color(0xFF2563EB); // Updated to a modern blue
  final Color secondaryColor = const Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Glassmorphism effect
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF40A98D),
                    ),
                  ),
                  // Overlay Pattern
                  CustomPaint(
                    painter: CirclePatternPainter(),
                  ),
                  // Profile Content
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Picture with Animation
                        Hero(
                          tag: 'profile_pic',
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 62,
                                    backgroundImage: NetworkImage(
                                      DairyOwnerSessionData.profilePic!,
                                    ),
                                    backgroundColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                              // Material(
                              //   elevation: 8,
                              //   borderRadius: BorderRadius.circular(30),
                              //   color: Colors.white,
                              //   child: InkWell(
                              //     borderRadius: BorderRadius.circular(30),
                              //     onTap: () {
                              //       // TODO: Implement image picking
                              //     },
                              //     child: Container(
                              //       padding: EdgeInsets.all(8),
                              //       child: Icon(
                              //         Icons.camera_alt_rounded,
                              //         color: primaryColor,
                              //         size: 20,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Name with Shadow
                        Text(
                          DairyOwnerSessionData.ownerName!,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        // Dairy Name with Blur Effect
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dairy Name: ${DairyOwnerSessionData.dairyName}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // actions: [
            //   // Modern Edit Button
            //   Padding(
            //     padding: EdgeInsets.only(right: 8),
            //     child: Material(
            //       color: Colors.white.withOpacity(0.2),
            //       borderRadius: BorderRadius.circular(12),
            //       child: InkWell(
            //         borderRadius: BorderRadius.circular(12),
            //         onTap: () {
            //           // TODO: Implement edit profile
            //         },
            //         child: Container(
            //           padding: EdgeInsets.all(8),
            //           child: Icon(Icons.edit_rounded, color: Colors.white),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
          ),

          // Contact Information
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildContactInfo(context),
            ),
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _buildContactItem(
              icon: Icons.location_on_rounded,
              title: 'Address',
              value: DairyOwnerSessionData.address ?? 'Not provided',
              color: Colors.blue,
            ),
            _buildContactItem(
              icon: Icons.phone_rounded,
              title: 'Phone',
              value: DairyOwnerSessionData.number ?? 'Not provided',
              color: Colors.green,
            ),
            _buildContactItem(
              icon: Icons.email_rounded,
              title: 'Email',
              value: DairyOwnerSessionData.email ?? 'Not provided',
              color: Colors.red,
              isLast: true,
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 3,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () async {
                  // Show confirmation dialog
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Logout',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirm) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 80,
      width: 1,
      color: Colors.grey[300],
    );
  }
}

// Custom Painter for background pattern
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final radius = size.width / 8;
    final centers = [
      Offset(-radius, -radius),
      Offset(size.width + radius, -radius),
      Offset(-radius, size.height + radius),
      Offset(size.width + radius, size.height + radius),
    ];

    for (var center in centers) {
      canvas.drawCircle(center, radius * 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
