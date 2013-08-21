data sasuser.bottle;
	input Units Line;
cards;
37	1
22	1
26	1
35	1
27	1
32	1
27	1
20	1
19	1
33	1
21	1
34	1
14	1
35	1
25	1
28	1
26	1
23	1
34	1
21	1
21	1
24	1
27	1
23	2
34	2
19	2
31	2
14	2
32	2
23	2
24	2
36	2
26	2
22	2
27	2
26	2
25	2
43	2
33	2
23	2
43	2
30	2
31	2
32	2
35	2
37	2
21  3
27  3
18  3
19  3
20  3
21  3
16  3
13  3
15  3
14  3
12  3
32  3
16  3
23  3
30  3
17  3
18  3
15  3
10  3
32  3
23  3
25  3
21  3
;
run;


data sasuser.salary;
	input Salary Experience Gender Age Communication Previous;
cards;
98.5	10	0	30	100	91.01
70.37	6	1	27	70	68.71
107.67	15	0	36	80	103.56
97.48	14	1	36	72	98.58
76.91	7	0	31	77	78.47
90.89	11	1	30	93	91.52
97.12	11	1	32	100	92.45
77.27	10	1	27	67	73.8
103.92	14	0	37	92	103.4
80.25	7	1	30	85	76.35
96.07	10	0	33	100	93.4
71.71	7	0	31	70	67.38
92.04	12	0	33	77	91.17
86.89	10	1	33	86	82.91
91.28	10	1	31	91	88.4
62.48	5	0	29	54	63.31
67.56	5	0	28	64	63.98
89.03	10	1	33	92	89.28
94.25	12	1	31	55	86.84
90.47	10	1	31	89	77.08
59.03	4	0	28	58	54.85
90.07	12	1	34	72	91.17
115.96	15	0	35	100	105.98
81.75	8	0	28	72	70.16
68.42	5	0	29	86	62.01
80.71	10	0	29	75	79.03
73.08	9	0	30	53	67.31
84.77	9	1	31	85	81.3
79.22	8	1	27	74	74.4
93.84	9	1	35	98	85.85
85.15	9	1	30	84	77.37
87.11	10	0	32	92	84.3
71.46	8	1	29	55	72.21
104.96	12	0	33	100	93.17
75.82	6	0	28	86	69
101.44	15	0	35	64	97.24
81.45	8	1	30	76	72.46
89.36	9	0	32	88	80.16
116.97	18	1	35	82	115.34
112.26	16	1	35	73	103.97
118.33	17	0	37	92	113.4
65.08	4	1	27	78	59.37
68.6	6	0	30	87	70.51
61.05	5	1	29	68	57.43
84.89	8	1	31	87	79.69
99.42	13	0	35	76	90.24
104.92	13	0	34	87	101.25
98.58	12	0	34	82	93.14
93.39	12	1	32	78	88.88
114.62	17	1	36	79	106.98
91.12	9	0	30	87	79.11
122.89	17	0	38	100	109.91
119.74	16	1	36	91	107.17
137.06	21	1	40	100	128.48
93.79	14	1	34	60	94.85
101.71	14	0	35	83	95.08
75.6	9	1	27	72	75.13
108.62	15	0	37	93	108.16
117	16	0	37	85	110.65
110.75	15	1	36	78	99.81
118.43	17	0	37	99	109.93
95.85	12	1	34	81	91.21
86.92	9	0	32	64	73.92
93.43	13	1	32	74	91.3
94.98	10	1	35	100	93.27
98.14	11	1	33	100	92.63
84.93	9	0	31	82	77.75
104.04	14	0	36	68	94.22
77.93	8	0	33	87	81.1
118.41	16	1	38	99	112.28
120.34	16	1	37	98	112.79
103.13	15	1	37	82	98.19
126.72	17	1	38	100	120.24
91.19	12	0	32	74	85.89
92.72	11	1	33	77	87.68
103.38	14	1	34	77	95.27
112.3	16	1	37	92	109.34
86.5	9	1	35	91	85.01
65.36	8	1	30	44	63.55
69.39	6	1	31	64	65.63
87.09	10	1	32	84	85.45
93.62	12	0	34	73	89.55
120.78	16	1	36	100	114.17
90.71	9	0	30	100	86.46
98.04	12	1	33	91	92.18
112.66	15	0	34	88	105.52
105.96	15	0	36	75	103.13
89.7	12	0	34	55	81.1
106.74	14	0	35	77	96.71
86.08	10	0	32	82	82.94
87.67	10	0	31	73	80.46
112.91	14	1	37	100	102.89
106.57	16	0	37	67	103
80.43	8	1	31	82	78.36
48.48	3	1	26	51	43.68
97.68	12	1	34	79	87.6
77.19	8	1	30	76	70.11
99.74	12	0	33	80	87.38
116.64	17	0	35	71	109.16
81.67	10	0	28	56	77.96
66.22	6	1	28	68	66.4
77.09	7	0	30	95	77.99
116.86	14	0	35	91	104.9
65.8	4	1	28	84	63.89
112.37	14	1	34	91	102.62
103.22	14	0	33	96	108.99
105.73	13	0	37	100	97.85
87.88	12	1	33	59	82.36
82.48	9	1	33	72	76.24
57.53	3	1	27	79	56.17
98.86	10	1	33	94	88.08
87.77	10	1	31	78	82.42
123.79	17	1	39	100	116.13
95.1	12	1	33	71	87.81
104.33	13	0	36	88	94.3
84.53	12	0	36	50	82.43
110.95	15	0	34	75	98.9
64.16	5	1	28	55	60.84
81.37	10	1	31	73	76.65
51.04	2	0	25	63	48.06
67.06	6	1	28	67	63.38
84.28	9	1	31	79	79.61
89.35	11	0	30	92	87.43
84.21	11	0	30	45	71.02
112.18	15	1	35	98	102.45
108.29	14	1	35	87	96.96
82.21	9	1	32	78	85.34
112.2	14	0	37	94	101.68
90.07	12	1	33	73	85.9
83.33	9	0	34	95	82.27
121.57	16	1	35	100	110.51
77.87	9	1	30	64	72.12
81.84	9	1	29	87	75.37
96.67	13	1	34	82	94.31
88.84	11	1	29	75	80.56
100.11	13	1	35	87	96.43
112.78	16	0	34	100	108.04
102.84	13	1	37	88	93.44
82.4	10	1	34	68	79.15
82.59	9	1	30	57	69.8
100.66	11	0	32	88	90.06
73.27	8	0	31	66	75.74
84.79	8	0	33	86	75.46
87.11	12	0	33	59	78.99
80.93	11	1	33	51	77.67
81.42	11	1	30	61	78.19
97.77	11	0	33	100	90.6
113.96	17	1	34	71	109.29
75.24	6	1	30	88	69.82
106.47	15	0	34	81	101.29
65.22	5	1	28	71	58.68
108.99	14	0	37	100	106.41
57.46	7	0	25	43	61.61
43.37	1	0	22	56	43.15
;
run;


data sasuser.pain;
	input Pain$ Treatment$ Age;
cards;
Yes	A	69
Yes	A	65
No	A	68
No	A	74
No	A	60
No	A	68
No	A	69
No	A	81
No	A	75
Yes	A	74
No	A	69
No	A	79
No	A	64
No	A	74
No	A	82
No	A	73
No	A	74
No	A	58
No	A	75
No	A	59
No	B	75
No	B	63
No	B	64
No	B	75
Yes	B	73
Yes	B	75
Yes	B	81
No	B	70
Yes	B	75
No	B	67
No	B	70
No	B	71
Yes	B	86
No	B	73
No	B	65
No	B	71
Yes	B	75
Yes	B	76
No	B	69
No	B	65
Yes	P	63
No	P	79
Yes	P	70
Yes	P	68
Yes	P	72
Yes	P	81
Yes	P	76
Yes	P	67
Yes	P	86
No	P	74
Yes	P	69
No	P	65
Yes	P	72
Yes	P	71
Yes	P	59
Yes	P	76
Yes	P	64
Yes	P	79
Yes	P	63
Yes	P	69
;
run;