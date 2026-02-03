import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorApp(),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _expression = '';
  String _result = '0';
  bool _showError = false;
  String _errorMessage = '';

  void _appendInput(String value) {
    setState(() {
      _showError = false;
      _expression += value;
      _updateResult();
    });
  }

  void _updateResult() {
    try {
      // Only try to evaluate if expression ends with a number or closing bracket
      if (_expression.isNotEmpty && !(_expression.endsWith('+') || _expression.endsWith('-') || _expression.endsWith('*') || _expression.endsWith('/'))) {
        final expression = Expression.parse(_expression);
        final evaluator = const ExpressionEvaluator();
        final result = evaluator.eval(expression, {});
        _result = result.toString();
        
        // Format the result to remove unnecessary decimals
        if (_result.contains('.')) {
          final num numResult = num.parse(_result);
          if (numResult == numResult.toInt()) {
            _result = numResult.toInt().toString();
          } else {
            // Keep only 8 decimal places for floating point results
            _result = double.parse(_result).toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
          }
        }
      } else {
        _result = '0';
      }
    } catch (e) {
      // If expression is incomplete or invalid, show 0 as result
      _result = '0';
    }
  }

  void _calculate() {
    try {
      _showError = false;
      if (_expression.isEmpty) {
        return;
      }

      final expression = Expression.parse(_expression);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
      
      String resultString = result.toString();
      
      // Format the result
      if (resultString.contains('.')) {
        final num numResult = num.parse(resultString);
        if (numResult == numResult.toInt()) {
          resultString = numResult.toInt().toString();
        } else {
          resultString = double.parse(resultString).toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
      }

      setState(() {
        _expression = resultString;
        _result = resultString;
      });
    } catch (e) {
      setState(() {
        _showError = true;
        _errorMessage = 'Invalid expression';
        _result = 'Error';
      });
    }
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '0';
      _showError = false;
      _errorMessage = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
        _updateResult();
      }
    });
  }

  void _addOperator(String op) {
    setState(() {
      _showError = false;
      if (_expression.isEmpty) {
        // Don't add operator if expression is empty
        return;
      }
      // Don't add operator if the last character is already an operator
      if (_expression.endsWith('+') || _expression.endsWith('-') || _expression.endsWith('*') || _expression.endsWith('/') || _expression.endsWith('%')) {
        // Replace the last operator
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
      _updateResult();
    });
  }

  void _square() {
    setState(() {
      _showError = false;
      if (_expression.isEmpty) {
        return;
      }
      // Wrap the entire expression in parentheses and square it
      _expression = '($(_expression))^2';
      _updateResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('James\'s Calculator'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Display
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expression display
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _expression.isEmpty ? '0' : _expression,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Result display
                        Text(
                          _result,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _showError ? Colors.red : Colors.black,
                          ),
                        ),
                        // Error message
                        if (_showError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Row 1: C, Backspace, x², %
                      Row(
                        children: [
                          _buildButton('C', _clear, Colors.red, Colors.white),
                          const SizedBox(width: 8),
                          _buildButton('⌫', _backspace, Colors.orange, Colors.white),
                          const SizedBox(width: 8),
                          _buildButton('x²', _square, Colors.purple, Colors.white),
                          const SizedBox(width: 8),
                          _buildOperatorButton('%', () => _addOperator('%')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 2: /, *, 7, 8
                      Row(
                        children: [
                          _buildOperatorButton('/', () => _addOperator('/')),
                          const SizedBox(width: 8),
                          _buildOperatorButton('*', () => _addOperator('*')),
                          const SizedBox(width: 8),
                          _buildNumberButton('7'),
                          const SizedBox(width: 8),
                          _buildNumberButton('8'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 3: 9, -, 4, 5
                      Row(
                        children: [
                          _buildNumberButton('9'),
                          const SizedBox(width: 8),
                          _buildOperatorButton('-', () => _addOperator('-')),
                          const SizedBox(width: 8),
                          _buildNumberButton('4'),
                          const SizedBox(width: 8),
                          _buildNumberButton('5'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 4: 6, +, 1, 2
                      Row(
                        children: [
                          _buildNumberButton('6'),
                          const SizedBox(width: 8),
                          _buildOperatorButton('+', () => _addOperator('+')),
                          const SizedBox(width: 8),
                          _buildNumberButton('1'),
                          const SizedBox(width: 8),
                          _buildNumberButton('2'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 5: 3, =, 0, .
                      Row(
                        children: [
                          _buildNumberButton('3'),
                          const SizedBox(width: 8),
                          _buildButton('=', _calculate, Colors.green, Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildButton(
                              '0',
                              () => _appendInput('0'),
                              Colors.blue[100]!,
                              Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildNumberButton('.'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: _buildButton(
        number,
        () => _appendInput(number),
        Colors.blue[100]!,
        Colors.black,
      ),
    );
  }

  Widget _buildOperatorButton(String operator, VoidCallback onPressed) {
    return Expanded(
      child: _buildButton(
        operator,
        onPressed,
        Colors.blue[300]!,
        Colors.white,
      ),
    );
  }

  Widget _buildButton(
    String label,
    VoidCallback onPressed,
    Color backgroundColor,
    Color textColor,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
