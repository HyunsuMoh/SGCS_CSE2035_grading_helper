import sys
import argparse

def getData(lines):
	result = []
	for line in lines:
		s = line.split()
		if s:
			result.append(s)
	return result


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='')
	parser.add_argument('filename',
						help='path to the answer file [REQUIRED]')

	args = parser.parse_args()
	f = open(args.filename)
	a = sys.stdin
	print(int(getData(f) == getData(a)))
