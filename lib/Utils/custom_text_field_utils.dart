import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboard,
    required this.isPassField,
    required this.isEmailField,
    required this.isPassConfirmField,
    required this.icon,
    this.pageIndex,
    this.maxLen,
    this.minLen,
    this.focusNode,
    // required this.formKey,
  });
  TextEditingController controller;
  String hintText;
  TextInputType keyboard;
  bool isPassField, isPassConfirmField, isEmailField;
  IconData icon;
  int? pageIndex;
  int? maxLen;
  int? minLen;
  FocusNode? focusNode;
  // GlobalKey<FormState> formKey;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passVisibility = false;
  bool passConfirmVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: TextFormField(
        focusNode: widget.focusNode,
        scrollPhysics: AppColors.scrollPhysics,
        maxLines: widget.maxLen,
        minLines: widget.minLen,
        toolbarOptions: (widget.isPassField || widget.isPassConfirmField)
            ? const ToolbarOptions(selectAll: true)
            : const ToolbarOptions(
                selectAll: true,
                copy: true,
                cut: true,
                paste: true,
              ),
        decoration: InputDecoration(
          errorStyle: TextStyle(
            overflow: TextOverflow.clip,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.white,
          ),
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
          suffixIcon: (widget.isPassField || widget.isPassConfirmField)
              ? IconButton(
                  icon: passVisibility
                      ? const Icon(
                          Icons.visibility,
                          color: AppColors.white,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: AppColors.white,
                        ),
                  onPressed: (() {
                    setState(() {
                      passVisibility = !passVisibility;
                    });
                  }),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
        ),
        validator: (widget.isEmailField)
            ? (email) => (email != null && !EmailValidator.validate(email))
                ? "Enter a valid email"
                : null
            : (widget.isPassField)
                ? ((password) {
                    if (password != null) {
                      if (password.length < 8) {
                        return "Password should contain minimum 8 characters";
                      }
                      if (!RegExp(r'^(?=.*[A-Z])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 Uppercase character";
                      }
                      if (!RegExp(r'^(?=.*[a-z])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 Lowercase character";
                      }
                      if (!RegExp(r'^(?=.*[0-9])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 numeric";
                      }
                      if (!RegExp(r'^(?=.*[@#₹_&-+()/*:;!?~`|$^=.,])\w+')
                          .hasMatch(password)) {
                        return "Password should contain minimum 1 special character";
                      }
                    }
                  })
                : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: widget.controller,
        keyboardType: widget.keyboard,
        cursorColor: AppColors.white,
        style: TextStyle(
          color: AppColors.white,
        ),
        obscureText: (passVisibility || passConfirmVisibility) ? true : false,
      ),
    );
  }
}
