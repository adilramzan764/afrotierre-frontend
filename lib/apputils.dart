import 'package:flutter/material.dart';

class AppUtils {
  largeLabelTextStyle({color}) {
    return TextStyle(
      color: color,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    );
  }

  smallHeadingTextStyle({color}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
  }

  smallHalfBoldTextStyle({color}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
  }

  smallBoldTextStyle({color}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
  }

  largeHeadingTextStyle({color}) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  tileText(text, color) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: color,
      ),
    );
  }

  tileTextStyle({color}) {
    return TextStyle(
      fontSize: 18,
      color: color,
    );
  }

  tileBoldTextStyle({color}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: color,
    );
  }

  tileHalfBoldTextStyle({color}) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: color,
    );
  }

  smallTitleTextStyle({color}) {
    return TextStyle(
      color: color,
      fontSize: 14,
    );
  }

  mediumTitleTextStyle({color}) {
    return TextStyle(
      fontSize: 15,
      color: color,
    );
  }

  mediumTitleBoldTextStyle({color}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  mediumTitleHalfBoldTextStyle({color}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  bigButton(
      {width,
      height,
      borderColor,
      onTap,
      borderWidth,
      borderRadius,
      containerColor,
      text,
      shadowColors,
      textColor,
      fontSize,
      fontWeight}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth == null ? 2 : borderWidth.toDouble()),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          color: containerColor ?? Colors.white,
        ),
        child: Center(
          child: Text(
            text.toString(),
            style: TextStyle(
              color: textColor ?? Colors.black,
              fontSize: fontSize == null ? 13.0 : fontSize.toDouble(),
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  textField(
      {controller,
      hintText,
      fontWeight,
      borderColor = Colors.black,
      width,
      height,
      fontSize,
      obscureText,
      labelText,
      keyboardType,
      maxLines,
      contentPadding,
      labelColor,
      suffixIcon,
      hintStyle,
      validator,
      textFormFieldColor,
      textFormFieldBorder,
      onChange}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              labelText,
              style: TextStyle(
                color: labelColor,
                fontSize: 16,
                fontWeight: fontWeight ?? FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: textFormFieldColor ?? Colors.transparent,
              borderRadius: textFormFieldBorder ?? BorderRadius.circular(0.0),
            ),
            child: TextFormField(
              maxLines: maxLines ?? 1,
              onChanged: onChange,
              validator: validator,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                suffixIconColor: Colors.black,
                contentPadding:
                    contentPadding ?? const EdgeInsets.only(top: 5, left: 15),
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: hintStyle ??
                    TextStyle(
                      color: Colors.grey,
                      fontSize: fontSize,
                    ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  button({
    onTap,
    width,
    height,
    fontSize,
    text,
    border,
    textColor,
    buttonColor,
    fontWeight,
    borderRadius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: buttonColor,
          border: border,
        ),
        width: width,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? 18,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  transactionsScreenWidget({
    onTap,
    onTap1,
    width,
    paymentCompany,
    description,
    date,
    price,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paymentCompany,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: width * 0.65,
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                    onTap: onTap1, child: const Icon(Icons.more_vert)),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  accountsScreenWidget({
    width,
    height,
    dates,
    totalBalance,
    cashCheck,
    amounts,
    details,
  }) {
    return Column(
      children: [
        for (int i = 0; i < dates.length; i++)
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.3,
                    child: const Divider(
                      color: Colors.grey,
                      height: 0.5,
                    ),
                  ),
                  Text(
                    dates[i],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(
                    width: width * 0.3,
                    child: const Divider(
                      color: Colors.grey,
                      height: 0.5,
                    ),
                  ),
                ],
              ),
              for (int j = 0; j < details.length; j++)
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: width,
                      height: 95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width * 0.6,
                                height: 40,
                                child: Text(
                                  details[j],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Text(
                                amounts[j],
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 0,
                          ),
                          Text(
                            cashCheck[j],
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          totalBalance[j],
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  accountsOverviewScreenWidget({
    width,
    height,
    amount,
    image,
    name,
    accountNumber,
  }) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.5,
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      width: width * 0.5,
                      child: Text(
                        accountNumber,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Colors.black26,
          height: 0.5,
        ),
      ],
    );
  }

  addBankAccountScreenWidget({
    image,
    name,
    onTap,
  }) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            GestureDetector(
              onTap: onTap,
              child: const Icon(Icons.add, color: Colors.grey, size: 25),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Colors.black26,
          height: 0.5,
        ),
      ],
    );
  }

  searchBar({
    controller,
    hintText,
    onChanged,
    border,
    keyboardType,
    borderRadius,
    padding,
    onTap,
    color,
  }) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(30.0),
        border: border,
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              onTap: onTap,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
