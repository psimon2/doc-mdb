import json
import argparse

def json_to_xpath(json_obj, current_path=""):
    """
    Recursively traverse a JSON object to extract XPath-like keys and associate values.
    """
    xpaths = {}
    if isinstance(json_obj, dict):
        for key, value in json_obj.items():
            new_path = f"{current_path}/{key}" if current_path else key
            xpaths.update(json_to_xpath(value, new_path))
    elif isinstance(json_obj, list):
        for index, value in enumerate(json_obj):
            new_path = f"{current_path}[{index}]"
            xpaths.update(json_to_xpath(value, new_path))
    else:
        xpaths[current_path] = json_obj
    return xpaths

def process_json_file(input_file_path, output_file_path, encoding='latin1'):
    """
    Process a file where each line is a JSON document, using a specified encoding.
    Write the output to a specified output file.
    """
    with open(input_file_path, 'r', encoding=encoding, errors='replace') as input_file, \
         open(output_file_path, 'w', encoding='utf-8') as output_file:

        for line_number, line in enumerate(input_file, start=1):
            try:
                json_obj = json.loads(line.strip())
                xpaths = json_to_xpath(json_obj)
                output_file.write(f"Document {line_number}:\n")
                for xpath, value in xpaths.items():
                    output_file.write(f"  {xpath}: {value}\n")
                output_file.write("\n")
            except json.JSONDecodeError as e:
                output_file.write(f"Error parsing JSON on line {line_number}: {e}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert JSON lines to XPath-like keys and save to output file.")
    parser.add_argument("input_file", help="Path to the input JSON file")
    parser.add_argument("output_file", help="Path to the output text file")
    args = parser.parse_args()

    process_json_file(args.input_file, args.output_file)
