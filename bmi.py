#!/usr/bin/env python3
"""Simple BMI calculator function with comments"""

def calculate_bmi(weight_kg, height_m):
    """Calculate BMI given weight in kilograms and height in meters.

    Args:
        weight_kg (float): Weight in kilograms.
        height_m (float): Height in meters.

    Returns:
        float: The Body Mass Index (BMI) rounded to 2 decimal places.
    """
    # Avoid division by zero: height must be positive
    if height_m <= 0:
        raise ValueError("Height must be greater than zero")

    # BMI formula: weight (kg) / (height (m))^2
    bmi = weight_kg / (height_m ** 2)

    # Return BMI rounded to 2 decimal places for readability
    return round(bmi, 2)


if __name__ == "__main__":
    # Example usage: prints BMI for 70kg and 1.75m
    print(calculate_bmi(70, 1.75))
