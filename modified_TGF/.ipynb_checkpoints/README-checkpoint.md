# Current issues

[temporary note posted on May 11th, 2023, by Kasra K.]

1. There are numerous cycles of length 1, in other words: `element['Main_ID'] = element['DS_Main_ID']`,
2. There are numerous cycles of length greater than 1,
3. There are non-connectivity issues between LineStrings between `element['Main_ID']` and `element['DS_Main_ID']`,
4. There are several cases where the `DS_Main_ID` does not show the appropriate value. In other words, the actual downstream segment of an element is not element['DS_Main_ID'].

# Funny mistakes of the TGF

[temporary note posted on May 19th, 2023, by Kasra K.]

1. There are hrus in the TGF which do not make sense. Initially, I thought that each river segment is associated with only 2 sub-basins, i.e., left-bank and right-bank. However, I've found out that this number varies for each river segment; sometimes a river segment is only associated with 1 sub-basin (covering both left-bank and right-bank), sometimes 2 (separate left-bank and right-bank), and in a number of occasions more than 2 (3 to 5). In the latter case (happening 92 times in `TGF`), the sub-basins could be in places that are not physically contributing to the river segment at all. Look at sub-basins with `hru_segment_nhm` ID of `57444` as an example.

2. Although it is not a mistake, sometimes there is a POI in the middle of the basin. This only happens in a few cases in TGF and is easily fixable: the important note is that `POI_ID` of each sub-basin is associated with the `Main_ID` of the most downstream river segment flowing within the sub-basin. Usually, there is a POI separating different sections of the river, however, this is not the case for every situation, and segments are separated even without a POI.

3. Sometimes, there are river without any sub-basin! Check out river segment with `Main_ID` of `55000800013888` where no sub-basin with this `POI_ID` can be found. Possible solution is dissolving it with its upstream segment, or changing the upstream segment to match its characteristics. For the case mentioned above (`Main_ID` of `55000800013888`), the `nhm_id_segment` matches the `hru_segment_nhm` of the sub-basin tho. Maybe some dissolving using the `nhm_id_segment` of the river segments are needed as well! Further examination is needed.