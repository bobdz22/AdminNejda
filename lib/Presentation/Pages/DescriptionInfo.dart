import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Descriptioninfo extends StatefulWidget {
   Descriptioninfo({super.key,required this.description,required this.clors});
   final String description;
   final Color clors;
  @override
  State<Descriptioninfo> createState() => _DescriptioninfoState();
}

class _DescriptioninfoState extends State<Descriptioninfo> {
  @override
Widget build(BuildContext context) {

  bool isArabic = _isArabicText(widget.description);
  
  return Directionality(
    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: isArabic 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
              
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: TextDirection.ltr,
                  children: [
                  
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: widget.clors.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:  widget.clors,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isArabic 
                                  ? Icons.arrow_forward_ios_rounded 
                                  : Icons.arrow_back_ios_new_rounded, 
                              color: Colors.white, 
                              size: 24
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer
                    SizedBox(width: 24),
                    
                    // Title with Modern Typography
                    Text(
                        "Description Details",
                        style: TextStyle(
                          color:  widget.clors,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    
                  ],
                ),
                
                // Vertical Spacing
                SizedBox(height: 32),
                
                // Description with Enhanced Styling
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xffF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:  widget.clors.withOpacity(0.1),
                      width: 1.5
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4)
                      )
                    ]
                  ),
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

bool _isArabicText(String text) {
  return text.contains(RegExp(r'[\u0600-\u06FF\u0750-\u077F]'));
}