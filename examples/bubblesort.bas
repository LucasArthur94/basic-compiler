1000 REM Quite BASIC Computer Science Project
1010 REM Bubble Sort program
1100 REM Initialize the array
1100 LET N = 10
1110 ARRAY A
1120 GOSUB 3000
1130 REM Print the random array
1140 PRINT "Random list:"
1150 GOSUB 4000
1160 REM Sort the array
1170 GOSUB 2000
1180 PRINT "Sorted list:"
1200 REM Print the sorted array
1210 GOSUB 4000
1220 END
2000 REM Bubble sort the list A of length N
2010 FOR I = 1 TO N - 1
2020 FOR J = 1 TO N - I
2030 IF A[J] <= A[J + 1] THEN GO TO 2070
2040 LET X = A[J]
2050 LET A[J] = A[J + 1]
2060 LET A[J + 1] = X
2070 NEXT J
2080 NEXT I
2090 RETURN
3000 REM Create random list of N integers
3030 FOR I = 1 TO N
3040 LET A[I] = FLOOR(RAND(100))
3070 NEXT I
3090 RETURN
4000 REM Print the list A
4010 FOR I = 1 TO N
4020 PRINT A[I];
4030 PRINT ", ";
4040 NEXT I
4050 PRINT
4060 RETURN
