# Examples

This directory contains example outputs from the Minimal Agentic Compose demo to show what you can expect.

## Fibonacci Example

**Problem:** "Calculate the first 10 Fibonacci numbers"

### Generated Code (`solution.js`)
```javascript
// Problem: Calculate the first 10 Fibonacci numbers
// Generated: 2024-07-19T10:30:45
// MCP Server: Alfonso Graziano's node-code-sandbox

function fibonacci(n) {
    const sequence = [0, 1];
    
    for (let i = 2; i < n; i++) {
        sequence[i] = sequence[i-1] + sequence[i-2];
    }
    
    return sequence;
}

const result = fibonacci(10);
console.log("First 10 Fibonacci numbers:", result);
console.log("Sum:", result.reduce((a, b) => a + b, 0));
```

### Execution Results (`result.txt`)
```
Coding Problem: Calculate the first 10 Fibonacci numbers
Timestamp: 2024-07-19T10:30:45.123456
MCP Server: Alfonso Graziano's node-code-sandbox
============================================================

Generated Code:
--------------------
function fibonacci(n) {
    const sequence = [0, 1];
    
    for (let i = 2; i < n; i++) {
        sequence[i] = sequence[i-1] + sequence[i-2];
    }
    
    return sequence;
}

const result = fibonacci(10);
console.log("First 10 Fibonacci numbers:", result);
console.log("Sum:", result.reduce((a, b) => a + b, 0));

Execution Results:
--------------------
✅ Execution: SUCCESS
Output:
First 10 Fibonacci numbers: [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34 ]
Sum: 88

Analysis:
--------------------
The solution correctly implements the Fibonacci sequence using an iterative approach. The code is clean, efficient, and includes helpful output for verification. The algorithm properly handles the base cases and computes the sequence in O(n) time complexity.
```

## Prime Numbers Example

**Problem:** "Create a function to find prime numbers under 100"

### Generated Code
```javascript
// Problem: Create a function to find prime numbers under 100
// Generated: 2024-07-19T10:35:22

function isPrime(num) {
    if (num < 2) return false;
    if (num === 2) return true;
    if (num % 2 === 0) return false;
    
    for (let i = 3; i <= Math.sqrt(num); i += 2) {
        if (num % i === 0) return false;
    }
    return true;
}

function findPrimesUnder(limit) {
    const primes = [];
    
    for (let i = 2; i < limit; i++) {
        if (isPrime(i)) {
            primes.push(i);
        }
    }
    
    return primes;
}

const primes = findPrimesUnder(100);
console.log(`Prime numbers under 100: ${primes}`);
console.log(`Count: ${primes.length}`);
console.log(`Largest prime: ${Math.max(...primes)}`);
```

### Output
```
Prime numbers under 100: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97
Count: 25
Largest prime: 97
```

## File Generation Example

**Problem:** "Generate a JSON file with sample user data"

### Generated Code
```javascript
// Problem: Generate a JSON file with sample user data
// Generated: 2024-07-19T10:40:15

import fs from 'fs/promises';

function generateRandomUser(id) {
    const firstNames = ['John', 'Jane', 'Mike', 'Sarah', 'David', 'Emma'];
    const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia'];
    const domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
    
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${domains[Math.floor(Math.random() * domains.length)]}`;
    
    return {
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        age: Math.floor(Math.random() * 50) + 18,
        active: Math.random() > 0.2,
        createdAt: new Date().toISOString()
    };
}

const users = [];
for (let i = 1; i <= 10; i++) {
    users.push(generateRandomUser(i));
}

const userData = {
    metadata: {
        count: users.length,
        generatedAt: new Date().toISOString(),
        version: "1.0"
    },
    users: users
};

await fs.writeFile('users.json', JSON.stringify(userData, null, 2));
console.log(`Generated ${users.length} sample users`);
console.log('Sample user:', JSON.stringify(users[0], null, 2));
console.log('File saved as users.json');
```

### Generated File (`users.json`)
```json
{
  "metadata": {
    "count": 10,
    "generatedAt": "2024-07-19T10:40:15.789Z",
    "version": "1.0"
  },
  "users": [
    {
      "id": 1,
      "firstName": "Sarah",
      "lastName": "Johnson",
      "email": "sarah.johnson@gmail.com",
      "age": 32,
      "active": true,
      "createdAt": "2024-07-19T10:40:15.789Z"
    }
    // ... 9 more users
  ]
}
```

## Error Handling Example

**Problem:** "Create intentionally broken code"

### Generated Code
```javascript
// This will fail intentionally
console.log("Starting broken code test");
undefinedFunction(); // This will cause an error
console.log("This won't execute");
```

### Result
```
Execution Results:
--------------------
❌ Execution: FAILED
Error: ReferenceError: undefinedFunction is not defined

Analysis:
--------------------
The code contains a reference to an undefined function which causes a ReferenceError. The error handling works correctly by capturing the exception and preventing the container from hanging.
```

## Real-World Examples

For more complex examples, try these problems:

```bash
# Data processing
PROBLEM="Read a CSV string and calculate statistics" docker-compose up

# Algorithm implementation  
PROBLEM="Implement a simple sorting algorithm with timing" docker-compose up

# Web scraping simulation
PROBLEM="Create a function that parses HTML-like strings" docker-compose up

# Mathematical computation
PROBLEM="Calculate pi using Monte Carlo method" docker-compose up
```

These examples demonstrate the versatility and reliability of the agentic system!
