import 'package:alrefadah/core/utils/components/height.dart';
import 'package:alrefadah/core/utils/constants/colors_constants.dart';
import 'package:alrefadah/core/widgets/end_of_page.dart';
import 'package:alrefadah/core/widgets/error_dialog.dart';
import 'package:alrefadah/cubit/auth_cubit/auth_cubit.dart';
import 'package:alrefadah/cubit/auth_cubit/auth_states.dart';
import 'package:alrefadah/screens/confirm_login/widgets/confirm_button.dart';
import 'package:alrefadah/screens/confirm_login/widgets/confirm_card_login_number_widget.dart';
import 'package:alrefadah/screens/confirm_login/widgets/custom_timer_widget.dart';
import 'package:alrefadah/screens/confirm_login/widgets/title_of_confirm_login_widget.dart';
import 'package:alrefadah/screens/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ConfirmLoginScreen extends StatefulWidget {
  const ConfirmLoginScreen({
    required this.phoneNumber,
    required this.identityNumber,
    super.key,
  });
  final String phoneNumber;
  final String identityNumber;
  @override
  State<ConfirmLoginScreen> createState() => _ConfirmLoginScreenState();
}

class _ConfirmLoginScreenState extends State<ConfirmLoginScreen> {
  bool _onEditing = true;
  String? code;
  bool _isInAsyncCall = false;
  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is LoginLoadingState) {
          setState(() {
            _isInAsyncCall = true;
          });
        } else if (state is LoginSuccessState) {
          setState(() {
            _isInAsyncCall = false;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (state is LoginWithCodeErrorState) {
          setState(() {
            _isInAsyncCall = false;
          });
          errorDialog(context);
        }
      },
      builder: (BuildContext context, AuthStates state) {
        final authCubit = context.read<AuthCubit>();
        return Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: _isInAsyncCall,
            opacity: 0.5,
            progressIndicator: const CircularProgressIndicator(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  bottom: isKeyboardVisible ? -260 : 0,
                  left: 0,
                  right: 0,
                  child: const EndOfPage(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const H(h: 40),
                          Image.asset('assets/images/logo.png', width: 110.w),
                          const H(h: 20),
                          const TitleOfConfirmLoginWidget(),
                          const H(h: 16),
                          ConfirmCardLoginNumberWidget(
                            phoneNumber: widget.phoneNumber,
                          ),
                          const H(h: 16),
                          Text(
                            'أكد هويتك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.43.h,
                            ),
                          ),
                          const H(h: 10),
                          Text(
                            'الرجاء إدخال كلمة المرور المرسلة ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w200,
                              height: 1.43.h,
                            ),
                          ),
                          const H(h: 30),

                          /// Verification code
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: VerificationCode(
                              length: 6,
                              margin: EdgeInsets.symmetric(horizontal: 2.sp),
                              underlineWidth: 1,
                              itemSize: 48.sp,
                              textStyle: TextStyle(
                                fontSize: 22.sp,
                                color: kMainColor,
                                fontFamily: 'FF Shamel Family',
                                fontWeight: FontWeight.w700,
                              ),
                              fullBorder: true,
                              underlineColor: kMainColor,
                              underlineUnfocusedColor: const Color(0xFFD3D3D3),
                              cursorColor: const Color(0xFFFCFCFC),
                              onCompleted: (String value) {
                                setState(() {
                                  code = value;
                                });
                              },
                              onEditing: (bool value) {
                                setState(() {
                                  _onEditing = value;
                                });
                                if (!_onEditing) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                          const H(h: 36),
                          Text(
                            'لم تتلقى الرمز؟',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.20.h,
                            ),
                          ),
                          const H(h: 16),

                          /// timer
                          const CustomTimerWidget(),
                          const H(h: 60),

                          /// Confirm button
                          ConfirmButton(
                            code: code,
                            authCubit: authCubit,
                            widget: widget,
                          ),
                          const H(h: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
