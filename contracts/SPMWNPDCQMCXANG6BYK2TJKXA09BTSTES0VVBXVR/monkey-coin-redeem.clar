(define-data-var paused bool true)
(define-data-var allowlist (list 100 principal) (list 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))

(define-constant err-not-authorized (err u403))

(define-constant GOLD u0)
(define-constant RED u1)
(define-constant GREEN u2)
(define-constant BLUE u3)

(define-private (check-mint-permissions)
  (or (not (var-get paused)) (is-some (index-of (var-get allowlist) tx-sender)))
)

(define-read-only (get-coin-color (id uint))
  (let (
      (gold-index (index-of GOLD-IDS id))
      (red-index (index-of RED-IDS id))
      (green-index (index-of GREEN-IDS id))
      (blue-index (index-of BLUE-IDS id))
    )
    (if (is-some gold-index) u0
      (if (is-some red-index) u1
        (if (is-some green-index) u2
          (if (is-some blue-index) u3 u4))))
  )
)

(define-private (check-coin-ownership-and-color (id uint) (color uint))
  (and 
    (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin get-owner id))) tx-sender)
    (is-eq (get-coin-color id) color)
    (is-none (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin get-listing-in-ustx id))
  )
)

(define-public (mint-standard (red-id uint) (green-id uint) (blue-id uint))
  (begin
    (asserts! (check-mint-permissions) err-not-authorized)
    (asserts! (check-coin-ownership-and-color red-id u1) err-not-authorized)
    (asserts! (check-coin-ownership-and-color green-id u2) err-not-authorized)
    (asserts! (check-coin-ownership-and-color blue-id u3) err-not-authorized)
    (try! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin burn red-id))
    (try! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin burn green-id))
    (try! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin burn blue-id))
    (try! (contract-call? .the-monkz claim false))
    (ok true)
  )
)

(define-public (mint-gold (gold-id uint))
  (begin
    (asserts! (check-mint-permissions) err-not-authorized)
    (asserts! (check-coin-ownership-and-color gold-id u0) err-not-authorized)
    (try! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin burn gold-id))
    (try! (contract-call? .the-monkz claim true))
    (try! (contract-call? .bitcoin-monkeys-mystery-box claim))
    (ok true)
  )
)

(define-public (set-paused (new-paused bool))
  (ok (var-set paused new-paused))
)

(define-public (set-allowlist (new-allowlist (list 100 principal)))
  (ok (var-set allowlist new-allowlist))
)

(define-constant RED-IDS (list 
u1005 u1009 u101 u1013 u1021 u103 u1030 u1034 u1039 u1042 u1048 u1051 u1052 u1054 u1055 u106 u1061 u1067 u107 u1070 u1074 u1077 u1078 u1079 u108 u1080 u1082 u1084 u1089 u1091 u1093 u1103 u1104 u1111 u1114 u1116 u1117 u1125 u1127 u1129 u1130 u1131 u1136 u1139 u1143 u1144 u1152 u1159 u1166 u1167 u1172 u1173 u1174 u118 u1180 u1186 u1191 u1192 u1196 u1202 u1204 u1207 u1209 u1210 u1211 u1214 u1217 u1220 u1224 u1229 u1234 u1238 u1239 u1240 u1243 u1244 u1246 u1249 u1250 u1251 u1253 u1254 u1256 u1265 u1270 u1273 u1274 u1276 u1277 u1280 u1282 u1283 u1289 u1291 u1292 u1296 u1302 u1303 u1304 u1305 u1306 u1310 u1313 u1314 u1315 u1316 u1323 u1325 u1327 u1329 u1334 u1335 u1337 u1340 u1341 u1342 u1344 u1347 u1348 u1350 u1352 u1353 u1356 u1359 u136 u1366 u137 u1370 u1372 u1375 u1376 u1386 u1389 u1393 u1396 u1397 u1402 u1405 u1408 u1409 u1412 u1414 u1415 u1416 u1419 u1423 u1426 u1427 u1428 u1431 u1434 u1436 u1437 u1440 u1441 u1442 u1443 u1448 u145 u1453 u1454 u1457 u146 u1464 u1465 u1467 u1469 u1478 u1482 u1487 u1489 u149 u1493 u1499 u15 u150 u1500 u1504 u1507 u1508 u1515 u1518 u152 u1521 u1522 u1526 u1527 u1528 u1529 u1530 u1531 u1535 u1538 u1540 u1541 u1543 u1545 u1548 u1549 u1557 u156 u1561 u1564 u1567 u157 u1570 u1571 u1574 u1581 u1582 u1584 u1586 u1593 u1594 u1595 u1597 u1599 u1600 u1601 u1604 u1606 u1608 u1609 u1612 u1613 u1616 u1617 u162 u1620 u1622 u1623 u1628 u1629 u1631 u1636 u1638 u164 u1640 u1642 u1644 u1657 u1658 u1663 u1664 u1667 u1668 u1669 u1670 u1672 u1676 u1684 u1686 u1688 u1691 u1692 u1702 u1711 u1712 u1713 u1719 u1723 u1724 u1725 u1726 u1727 u173 u1731 u1732 u1735 u174 u1740 u1742 u1749 u175 u1754 u1755 u1756 u1760 u1763 u1769 u1771 u1776 u1778 u1781 u1786 u1789 u179 u1790 u1792 u1794 u1797 u1798 u1799 u1800 u1803 u1804 u1805 u1807 u1809 u1812 u1816 u1817 u1818 u1821 u1825 u1826 u1828 u1830 u1834 u1835 u1841 u1842 u1843 u1844 u1847 u1848 u1851 u1857 u1864 u1869 u187 u1870 u1875 u1877 u1878 u1882 u1883 u1884 u1885 u1890 u1891 u1893 u1897 u19 u1903 u1904 u1906 u1917 u1919 u1923 u1929 u193 u1934 u194 u1940 u1943 u1945 u1948 u1950 u1956 u1957 u1958 u196 u1960 u1962 u1968 u1972 u1975 u1976 u1981 u1984 u1986 u1989 u1992 u1993 u1999 u2 u2000 u2001 u2006 u2009 u201 u2010 u2013 u2024 u203 u2036 u2041 u2043 u2050 u2055 u2057 u206 u2063 u2067 u2068 u2076 u2077 u2087 u2089 u209 u2091 u2094 u2097 u2103 u2108 u2112 u2119 u2122 u2126 u2127 u2128 u2139 u215 u2154 u2155 u2158 u216 u2167 u2171 u2172 u2177 u2179 u2187 u2188 u2189 u219 u2196 u2198 u2200 u2205 u2206 u2209 u221 u2210 u2216 u222 u2220 u2223 u2225 u2226 u2229 u2242 u2244 u2246 u2247 u225 u2251 u2257 u2269 u227 u2272 u2275 u228 u2285 u2287 u2291 u2299 u2301 u2310 u2315 u2323 u2329 u233 u2332 u2333 u2334 u234 u2347 u2348 u235 u2350 u2356 u2357 u2358 u2359 u2362 u2363 u2365 u2366 u2370 u2371 u2372 u2375 u2377 u2379 u2381 u2383 u2384 u2389 u2391 u2397 u240 u2401 u2402 u2408 u2409 u2418 u2421 u2427 u2429 u2435 u2436 u2438 u2440 u2443 u2444 u2450 u2453 u2457 u2468 u2470 u2471 u2472 u2473 u2476 u2477 u2482 u2484 u2485 u2492 u2495 u2497 u2498 u250 u252 u253 u258 u26 u261 u264 u27 u271 u274 u277 u28 u287 u289 u299 u30 u303 u304 u312 u316 u32 u322 u324 u333 u34 u340 u342 u344 u346 u356 u359 u362 u363 u364 u37 u371 u376 u383 u384 u387 u389 u39 u395 u40 u401 u425 u426 u429 u431 u432 u435 u436 u438 u439 u443 u450 u451 u452 u454 u46 u461 u462 u467 u47 u48 u484 u485 u492 u497 u5 u500 u503 u507 u514 u522 u528 u530 u533 u534 u54 u540 u547 u555 u558 u559 u562 u563 u569 u57 u577 u579 u583 u584 u592 u596 u599 u60 u61 u614 u615 u62 u622 u624 u626 u627 u629 u632 u637 u639 u641 u644 u649 u65 u651 u656 u659 u661 u662 u669 u67 u673 u676 u680 u684 u686 u689 u69 u691 u696 u698 u7 u700 u702 u703 u706 u707 u708 u709 u711 u723 u731 u735 u736 u738 u739 u74 u740 u741 u744 u749 u751 u753 u757 u76 u762 u769 u771 u775 u779 u78 u781 u788 u791 u794 u796 u798 u799 u8 u81 u810 u811 u812 u816 u817 u821 u824 u825 u828 u829 u830 u834 u837 u841 u842 u847 u849 u851 u856 u859 u863 u865 u871 u874 u878 u879 u884 u885 u887 u89 u891 u892 u894 u896 u900 u908 u911 u913 u92 u927 u928 u931 u934 u935 u937 u94 u942 u943 u948 u952 u953 u956 u959 u961 u964 u965 u967 u975 u976 u98 u980 u981 u985 u99 u991 u993 u999
))
(define-constant GREEN-IDS (list 
u1000 u1001 u1006 u1007 u1016 u102 u1020 u1026 u1027 u1029 u1031 u1035 u1036 u1037 u104 u1041 u1044 u1045 u1047 u1049 u105 u1057 u1062 u1064 u1065 u1068 u1069 u1071 u1076 u1081 u1083 u1085 u1086 u1090 u1092 u1097 u1105 u1108 u1109 u1112 u1115 u1119 u1121 u1122 u1123 u1132 u1133 u1141 u1149 u1150 u1153 u1155 u1156 u1157 u1158 u116 u1165 u1168 u117 u1176 u1179 u1183 u1188 u1189 u1190 u1193 u1195 u12 u1200 u1201 u1206 u1216 u1218 u1219 u1222 u123 u1232 u1233 u1235 u1237 u1241 u1242 u1247 u125 u1252 u1259 u126 u1263 u1267 u1268 u127 u1278 u128 u1281 u1284 u1288 u129 u1294 u1299 u130 u1307 u1308 u131 u1312 u1318 u1319 u1320 u1322 u1326 u133 u1332 u134 u1346 u1349 u1354 u1360 u1361 u1363 u1364 u1368 u1371 u1382 u1385 u1390 u1395 u1399 u1400 u1403 u1407 u1410 u1411 u1413 u1421 u1422 u1425 u143 u1430 u1435 u1438 u1439 u144 u1444 u1445 u1447 u1450 u1452 u1455 u1458 u1459 u1460 u147 u1472 u1474 u1480 u1481 u1483 u1484 u1485 u1488 u1494 u1498 u1501 u1503 u1506 u1509 u1510 u1511 u1514 u1516 u1519 u1524 u1525 u153 u1534 u1539 u154 u1550 u1556 u1559 u1560 u1568 u1569 u1576 u1578 u1583 u1585 u1589 u16 u1607 u161 u1610 u1614 u1615 u1625 u163 u1632 u1633 u1635 u1637 u1639 u1646 u1647 u1649 u1653 u1660 u1661 u1671 u1678 u168 u1680 u1681 u1682 u1687 u1689 u169 u1694 u1695 u1696 u1699 u17 u1705 u1707 u1709 u171 u1710 u172 u1722 u1728 u1729 u1730 u1733 u1734 u1736 u1739 u1741 u1743 u1757 u1758 u1764 u1765 u1766 u177 u1770 u1772 u1773 u1777 u1779 u178 u1780 u1783 u1785 u1788 u1791 u1793 u180 u1802 u181 u1810 u1811 u1813 u1815 u1819 u182 u1820 u1822 u1824 u183 u1833 u1837 u1839 u1850 u1853 u1854 u1858 u1860 u1866 u1872 u1874 u1876 u1887 u1892 u1895 u1896 u1898 u1907 u1912 u1913 u1915 u192 u1920 u1921 u1922 u1924 u1926 u1932 u1935 u1941 u1944 u1947 u1955 u1959 u1964 u1969 u197 u1973 u1980 u1987 u1988 u1991 u1996 u200 u2002 u2005 u2008 u2014 u2015 u2018 u2022 u2023 u2026 u2028 u2030 u2032 u2033 u2034 u2035 u2039 u2040 u2042 u2044 u2046 u2048 u2049 u205 u2051 u2052 u2053 u2056 u2058 u2061 u2064 u2066 u2069 u2070 u2073 u2075 u208 u2080 u2081 u2083 u2085 u2090 u2092 u2098 u2099 u21 u210 u2102 u2107 u2109 u2111 u2114 u2116 u2123 u2124 u2129 u213 u2131 u2132 u2137 u2138 u214 u2141 u2142 u2144 u2145 u2146 u2147 u2148 u2149 u2150 u2153 u2156 u2157 u2159 u2169 u2170 u2174 u2175 u2176 u2178 u2181 u2183 u2184 u2185 u2192 u2195 u2197 u22 u2201 u2203 u2213 u2214 u2218 u223 u2231 u2237 u2238 u224 u2240 u2245 u2248 u2249 u2258 u2259 u2262 u2263 u2265 u2266 u2268 u2270 u2273 u2276 u2284 u2288 u2290 u2292 u2293 u2294 u2295 u2297 u2300 u2302 u2305 u2307 u231 u2314 u2317 u2325 u2335 u2338 u2339 u2340 u2341 u2342 u2346 u2349 u2351 u2353 u2354 u2355 u236 u2361 u2376 u2378 u2380 u2382 u2386 u2387 u2392 u2393 u2395 u2396 u2398 u2399 u2400 u2403 u2406 u2407 u2410 u2412 u2413 u2414 u2416 u2420 u2428 u2439 u2442 u2446 u2447 u2448 u2449 u2452 u2455 u2456 u2458 u2461 u2463 u2466 u2467 u2469 u247 u2480 u2481 u2486 u2488 u2489 u249 u2491 u2493 u2499 u2500 u256 u262 u265 u266 u267 u268 u270 u279 u283 u284 u286 u288 u290 u292 u294 u295 u296 u297 u298 u305 u306 u310 u313 u314 u317 u318 u319 u323 u327 u329 u331 u337 u339 u341 u345 u347 u35 u352 u355 u357 u358 u36 u361 u367 u368 u370 u373 u375 u378 u38 u388 u390 u391 u393 u398 u400 u405 u407 u41 u410 u412 u413 u414 u417 u418 u419 u422 u430 u433 u437 u440 u444 u446 u448 u453 u457 u459 u463 u465 u466 u470 u471 u480 u481 u486 u489 u490 u493 u494 u499 u501 u502 u506 u51 u516 u517 u518 u520 u523 u526 u53 u532 u537 u538 u539 u546 u55 u554 u557 u565 u566 u570 u571 u576 u578 u58 u585 u586 u587 u588 u593 u605 u608 u613 u617 u620 u621 u628 u63 u630 u633 u640 u646 u653 u655 u658 u660 u664 u667 u671 u674 u675 u677 u679 u68 u681 u690 u692 u694 u70 u710 u712 u714 u716 u717 u718 u72 u721 u728 u732 u734 u737 u743 u745 u747 u755 u756 u763 u764 u767 u768 u77 u772 u773 u774 u776 u778 u783 u784 u789 u793 u795 u797 u802 u804 u806 u815 u826 u827 u831 u839 u843 u848 u85 u853 u86 u861 u862 u867 u868 u869 u872 u873 u875 u881 u882 u883 u888 u889 u890 u897 u899 u9 u90 u902 u903 u904 u905 u912 u915 u917 u918 u920 u922 u923 u924 u93 u933 u936 u938 u940 u949 u951 u955 u957 u962 u968 u969 u970 u973 u977 u982 u984 u988 u989 u990 u994 u998
))
(define-constant BLUE-IDS (list 
u1 u10 u100 u1002 u1003 u1008 u1011 u1015 u1019 u1022 u1025 u1033 u1038 u1040 u1043 u1046 u1050 u1053 u1059 u1063 u1066 u1072 u1075 u1087 u109 u1094 u1095 u1096 u1098 u1099 u11 u110 u1100 u1102 u1106 u1107 u111 u1110 u1113 u1118 u112 u1120 u1128 u113 u1134 u1135 u114 u1142 u1145 u1146 u1147 u1148 u115 u1151 u1161 u1164 u1169 u1171 u1175 u1184 u1185 u1187 u1198 u120 u1203 u1208 u121 u1212 u1215 u122 u1227 u1228 u1230 u1231 u1236 u124 u1245 u1248 u1255 u1257 u1260 u1261 u1266 u1269 u1271 u1272 u1275 u1279 u1285 u1287 u1290 u1295 u1298 u13 u1300 u1301 u1311 u1317 u1324 u1328 u1330 u1333 u1336 u1338 u1339 u1343 u135 u1355 u1357 u1358 u1362 u1367 u1369 u1373 u1374 u1377 u1378 u138 u1381 u1383 u1384 u1388 u1391 u1392 u1394 u1398 u14 u140 u1404 u141 u1417 u1418 u1420 u1429 u1432 u1433 u1446 u1451 u1456 u1461 u1463 u1466 u1468 u1470 u1475 u1476 u1477 u1479 u148 u1486 u1490 u1492 u1495 u1496 u1497 u1502 u151 u1512 u1513 u1517 u1520 u1523 u1532 u1533 u1537 u1544 u1546 u1547 u155 u1551 u1553 u1558 u1562 u1563 u1565 u1572 u1573 u1575 u1577 u1579 u158 u1580 u1587 u1588 u1590 u1596 u1598 u1602 u1605 u1611 u1618 u1621 u1624 u1626 u1627 u1643 u1648 u165 u1650 u1651 u1652 u1654 u1655 u1659 u1662 u1666 u167 u1673 u1674 u1675 u1677 u1679 u1683 u1685 u1690 u1693 u1697 u1698 u1700 u1703 u1714 u1715 u1716 u1717 u1737 u1738 u1744 u1745 u1746 u1747 u1748 u1753 u176 u1761 u1762 u1767 u1768 u1774 u1775 u1782 u1784 u1787 u1795 u1796 u1806 u1823 u1827 u1829 u1831 u1836 u1838 u1840 u1846 u1849 u1852 u1855 u1856 u1859 u186 u1861 u1862 u1863 u1865 u1868 u1871 u1873 u1879 u188 u1880 u1881 u1886 u1888 u1889 u1894 u1899 u190 u1900 u1901 u1902 u1908 u1909 u1911 u1927 u1928 u1931 u1933 u1936 u1937 u1938 u1939 u1942 u1946 u1949 u195 u1951 u1953 u1954 u1961 u1963 u1965 u1966 u1967 u1970 u1971 u1974 u1977 u1978 u1979 u198 u1982 u1983 u199 u1990 u1994 u1995 u1997 u20 u2003 u2004 u2007 u2011 u2012 u2016 u2017 u202 u2020 u2021 u2025 u2027 u2031 u2037 u2038 u204 u2047 u2054 u2059 u2060 u2062 u2065 u2071 u2072 u2074 u2078 u2082 u2084 u2086 u2088 u2095 u2100 u2101 u2106 u211 u2110 u2113 u2115 u2117 u212 u2121 u2125 u2130 u2133 u2136 u2140 u2143 u2151 u2152 u2160 u2163 u2165 u2166 u2168 u217 u218 u2180 u2182 u2186 u2191 u2193 u2199 u220 u2204 u2208 u2211 u2212 u2215 u2217 u2221 u2222 u2228 u2230 u2232 u2233 u2234 u2235 u2239 u2243 u2252 u2253 u2254 u2255 u2256 u226 u2261 u2264 u2267 u2277 u2278 u2279 u2282 u2289 u229 u2296 u2298 u23 u230 u2303 u2304 u2306 u2313 u2316 u2318 u2319 u232 u2320 u2321 u2322 u2324 u2326 u2327 u2330 u2336 u2337 u2343 u2345 u2352 u2364 u2367 u2368 u2369 u237 u2373 u2374 u238 u2385 u239 u2390 u2394 u24 u2404 u2405 u241 u2415 u2417 u2419 u242 u2422 u2424 u2425 u2426 u243 u2430 u2431 u2433 u2434 u2437 u2441 u245 u2451 u2454 u2459 u246 u2462 u2464 u2465 u2478 u2479 u248 u2483 u2487 u2490 u2494 u25 u254 u255 u259 u260 u269 u272 u273 u275 u281 u282 u285 u29 u291 u293 u3 u300 u301 u302 u308 u309 u311 u315 u320 u321 u325 u328 u332 u334 u335 u338 u343 u348 u349 u353 u354 u360 u366 u369 u372 u374 u377 u379 u380 u381 u382 u385 u386 u392 u394 u396 u397 u399 u4 u402 u403 u406 u411 u416 u42 u420 u423 u424 u427 u428 u43 u434 u44 u441 u442 u445 u447 u449 u45 u455 u456 u458 u460 u464 u468 u473 u474 u475 u477 u478 u479 u482 u483 u487 u49 u491 u495 u496 u50 u504 u505 u510 u512 u513 u515 u519 u52 u521 u525 u527 u529 u531 u536 u541 u542 u544 u545 u548 u549 u550 u551 u552 u553 u56 u560 u564 u567 u568 u573 u574 u575 u580 u582 u591 u594 u595 u598 u6 u600 u601 u602 u603 u607 u609 u610 u612 u616 u618 u619 u623 u625 u634 u635 u636 u638 u64 u643 u645 u648 u650 u652 u654 u657 u66 u663 u665 u666 u668 u672 u678 u682 u683 u687 u688 u693 u695 u701 u71 u713 u715 u719 u720 u724 u725 u726 u727 u729 u73 u730 u733 u742 u746 u75 u750 u752 u754 u758 u760 u761 u765 u766 u777 u780 u782 u785 u786 u787 u79 u790 u80 u800 u801 u803 u805 u807 u808 u813 u814 u819 u82 u820 u822 u823 u83 u832 u833 u836 u838 u840 u844 u845 u846 u850 u852 u854 u855 u857 u858 u864 u87 u870 u876 u877 u88 u880 u898 u901 u906 u907 u91 u910 u916 u919 u921 u925 u930 u932 u939 u944 u946 u947 u95 u950 u954 u960 u966 u97 u971 u972 u974 u978 u986 u992 u997
))

(define-constant GOLD-IDS (list 
u1004 u1010 u1012 u1014 u1017 u1018 u1023 u1024 u1028 u1032 u1056 u1058 u1060 u1073 u1088 u1101 u1124 u1126 u1137 u1138 u1140 u1154 u1160 u1162 u1163 u1170 u1177 u1178 u1181 u1182 u119 u1194 u1197 u1199 u1205 u1213 u1221 u1223 u1225 u1226 u1258 u1262 u1264 u1286 u1293 u1297 u1309 u132 u1321 u1331 u1345 u1351 u1365 u1379 u1380 u1387 u139 u1401 u1406 u142 u1424 u1449 u1462 u1471 u1473 u1491 u1505 u1536 u1542 u1552 u1554 u1555 u1566 u159 u1591 u1592 u160 u1603 u1619 u1630 u1634 u1641 u1645 u1656 u166 u1665 u170 u1701 u1704 u1706 u1708 u1718 u1720 u1721 u1750 u1751 u1752 u1759 u18 u1801 u1808 u1814 u1832 u184 u1845 u185 u1867 u189 u1905 u191 u1910 u1914 u1916 u1918 u1925 u1930 u1952 u1985 u1998 u2019 u2029 u2045 u207 u2079 u2093 u2096 u2104 u2105 u2118 u2120 u2134 u2135 u2161 u2162 u2164 u2173 u2190 u2194 u2202 u2207 u2219 u2224 u2227 u2236 u2241 u2250 u2260 u2271 u2274 u2280 u2281 u2283 u2286 u2308 u2309 u2311 u2312 u2328 u2331 u2344 u2360 u2388 u2411 u2423 u2432 u244 u2445 u2460 u2474 u2475 u2496 u251 u257 u263 u276 u278 u280 u307 u31 u326 u33 u330 u336 u350 u351 u365 u404 u408 u409 u415 u421 u469 u472 u476 u488 u498 u508 u509 u511 u524 u535 u543 u556 u561 u572 u581 u589 u59 u590 u597 u604 u606 u611 u631 u642 u647 u670 u685 u697 u699 u704 u705 u722 u748 u759 u770 u792 u809 u818 u835 u84 u860 u866 u886 u893 u895 u909 u914 u926 u929 u941 u945 u958 u96 u963 u979 u983 u987 u995 u996
))