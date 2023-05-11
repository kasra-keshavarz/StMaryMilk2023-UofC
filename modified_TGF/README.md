# Current issues

[temporary note posted on May 11th, 2023 by Kasra K.]

1. There are numerous cycles of length 1, in other words: `element['Main_ID'] = element['DS_Main_ID']`,
2. There are numerous cycles of length greater than 1,
3. There are non-connectivity issues between LineStrings between `element['Main_ID']` and `element['DS_Main_ID']`,
4. There are several cases where the `DS_Main_ID` does not show the appropriate value. In other words, the actual downstream segment of an element is not element['DS_Main_ID'].


