//Find the sum of all the multiples of 3 or 5 below 1000.

let isMultOfThreeOrFive = (x) => x % 3 === 0 || x % 5 === 0;

let sum = 0;

for (let i = 0; i < 1000; i++) {
	sum += isMultOfThreeOrFive(i) ? i : 0
}

console.log(sum) // 233168
