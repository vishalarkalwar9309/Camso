import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import '../theme/colors.dart';

class ScreenShell extends StatelessWidget {
 final Widget child; final bool bottomNav; final PreferredSizeWidget? appBar;
 const ScreenShell({super.key,required this.child,this.bottomNav=true,this.appBar});
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:AppColors.bg,appBar:appBar,body:child,bottomNavigationBar:bottomNav?const CamsoBottomNav():null);
}
