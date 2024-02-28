/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_NUM

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"==", TK_EQ},        // equal
	{"-", '-'},						// minus
	{"\\*", '*'},					// multiply
	{"/", '/'},						// devide
	{"\\(", '('},					// left bracket
	{"\\)", ')'},					// right bracket
	{"\\d+", TK_NUM}			// number
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
					case TK_NOTYPE:
						break;
					case TK_NUM: 
						memcpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
          default:
						tokens[nr_token].type = rules[i].token_type;
						++nr_token;
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

word_t eval(int p, int q, bool *success);
bool check_parentheses(int p, int q);
int pos_of_maincomp(int p, int q, bool *success);

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }
	return eval(0, nr_token-1, success);
}

  /* TODO: Insert codes to evaluate the expression. */
word_t eval(int p, int q, bool *success) {
	if (p > q) {
		*success = false;
		assert(0);
		return 0;
	}
	else if (p == q) {
		return atoi(tokens[p].str);
	}
	else if (check_parentheses(p, q)) {
		return eval(p + 1, q - 1, success); 
	}
	else {
		int op = pos_of_maincomp(p, q, success);
		word_t val1 = eval(p, op-1, success);
		word_t val2 = eval(op+1, q, success);
		int op_type = tokens[op].type;

		switch (op_type) {
			case '+': return val1 + val2;
			case '-': return val1 - val2;
			case '*': return val1 * val2;
			case '/': return val1 / val2;
			default: assert(0);
		}
	}
}

bool check_parentheses(int p, int q) {
	if(tokens[p].type != '(' || tokens[q].type != ')')
		return false;
	int num = 0;
	int i = p + 1;
	for (; i < q; ++i) {
		if (tokens[i].type == '(')
			++num;
		else if (tokens[i].type == ')')
			--num;
		if (num < 0) return false;
	}
	if (num > 0) return false;
	return true;
}

int pos_of_maincomp(int p, int q, bool *success) {
	int bracket = 0;
	int i = p;
	int pos = p;
	bool is_plus = false;
	for (; i <= q; ++i) {
		if (tokens[i].type == '(')
			++bracket;
		else if (tokens[i].type == ')')
			--bracket;
		if (bracket < 0) *success = false;
		if (bracket > 0) continue;
		if (tokens[i].type == '+' || tokens[i].type == '-') {
			pos = i;
			is_plus = true;
		}
		else if (tokens[i].type == '*' || tokens[i].type == '/') {
			if (!is_plus) pos = i;
		}
	}
	return pos;
}
