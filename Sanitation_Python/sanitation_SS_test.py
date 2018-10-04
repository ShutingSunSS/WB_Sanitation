# Programmer:  Shuting Sun
# Time:        Oct 4, 2018
# Description: The unittest of sanitation_SS.py
#              To test part of the testable functions

# from math import *
from sanitation_SS import *   # import everything from sanitation_SS.py
import unittest  # This loads the testing methods and a main program

class sanitation_SS(unittest.TestCase):

    def test_countries_incomelevel(self):                                         
        self.assertIn("CHN", countries_incomelevel("UMC"))
        self.assertIn("USA", countries_incomelevel("HIC"))

    def test_multiply_two_columns(self):
        df = wbdata.get_dataframe(indicators, country = ["SEN","NER","SOM"], convert_date = False)
        self.assertEqual(len(multiply_two_columns(df, "sanitation", "population", "mul").columns), 3)

    def test_divide_two_columns(self):
        df = wbdata.get_dataframe(indicators, country = ["SEN","NER","SOM"], convert_date = False)
        self.assertEqual(len(divide_two_columns(df, "sanitation", "population", "div").columns), 3)

    def test_sum_at_index(self):
        df = wbdata.get_dataframe(indicators, country = ["BRA", "VGB", "BOL", "BIH", "BWA"], convert_date = False)
        self.assertEqual(len(sum_at_index(df, "country")), 5)

    def test_clean_data(self):
        df = wbdata.get_dataframe(indicators_sanitation, country = ["WLD"], convert_date = False)
        df1 = clean_data(df)
        self.assertFalse(df1.isnull().values.any())
        
unittest.main()
