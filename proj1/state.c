#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "snake_utils.h"
#include "state.h"
#include <assert.h>
#include <sys/stat.h>
#include <aio.h>

/* Helper function definitions */
static char get_board_at(game_state_t *state, int x, int y);
static void set_board_at(game_state_t *state, int x, int y, char ch);
static bool is_tail(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static int incr_x(char c);
static int incr_y(char c);
static void find_head(game_state_t *state, int snum);
static char next_square(game_state_t *state, int snum);
static void update_tail(game_state_t *state, int snum);
static void update_head(game_state_t *state, int snum);

/* Helper function to get a character from the board (already implemented for you). */
static char get_board_at(game_state_t *state, int x, int y)
{
  return state->board[y][x];
}

/* Helper function to set a character on the board (already implemented for you). */
static void set_board_at(game_state_t *state, int x, int y, char ch)
{
  state->board[y][x] = ch;
}

/* Task 1 */
game_state_t *create_default_state()
{
  // TODO: Implement this function.
  game_state_t *default_game_state = (game_state_t *)malloc(sizeof(game_state_t));
  default_game_state->x_size = DEFAULT_X;
  default_game_state->y_size = DEFAULT_Y;
  default_game_state->board = (char **)malloc(sizeof(char *) * DEFAULT_Y);
  for (int i = 0; i < DEFAULT_Y; i++)
  {
    default_game_state->board[i] = (char *)malloc(sizeof(char) * DEFAULT_X);
  }
  // snakes setup
  default_game_state->snakes = (snake_t *)malloc(sizeof(snake_t));
  default_game_state->snakes[0].head_x = 5;
  default_game_state->snakes[0].head_y = 4;
  default_game_state->snakes[0].tail_x = 4;
  default_game_state->snakes[0].tail_y = 4;
  default_game_state->snakes[0].live = true;
  default_game_state->num_snakes = 1;
  // board drawing
  strncpy(default_game_state->board[0], "##############", 14);
  strncpy(default_game_state->board[DEFAULT_Y - 1], "##############", 14);
  for (int i = 1; i < DEFAULT_Y - 1; i++)
  {
    strncpy(default_game_state->board[i], "#            #", 14);
  }
  default_game_state->board[2][9] = '*';
  default_game_state->board[4][4] = 'd';
  default_game_state->board[4][5] = '>';
  return default_game_state;
}

/* Task 2 */
void free_state(game_state_t *state)
{
  // TODO: Implement this function.
  for (int i = 0; i < state->y_size; i++)
  {
    free(state->board[i]);
  }

  free(state->snakes);
  free(state->board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp)
{
  // TODO: Implement this function.
  for (int i = 0; i < state->y_size; i++)
  {
    fprintf(fp, "%s\n", state->board[i]);
  }
  return;
}

/* Saves the current state into filename (already implemented for you). */
void save_board(game_state_t *state, char *filename)
{
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */
static bool is_tail(char c)
{
  // TODO: Implement this function.
  char *s = "wasd";
  for (int i = 0; i < strlen(s); i++)
  {
    if (s[i] == c)
    {
      return true;
    }
  }
  return false;
}

static bool is_snake(char c)
{
  // TODO: Implement this function.
  char *s = "wasd^<>vx";
  for (int i = 0; i < strlen(s); i++)
  {
    if (s[i] == c)
    {
      return true;
    }
  }
  return false;
}
static bool is_snake_init(char c)
{
  // TODO: Implement this function.
  char *s = "wasd^<>v";
  for (int i = 0; i < strlen(s); i++)
  {
    if (s[i] == c)
    {
      return true;
    }
  }
  return false;
}

static char body_to_tail(char c)
{
  // TODO: Implement this function.
  switch (c)
  {
  case '^':
    return 'w';
  case '<':
    return 'a';
  case '>':
    return 's';
  case 'v':
    return 'd';
  default:
    assert(false);
  }
  return 'x';
}

static int incr_x(char c)
{
  // TODO: Implement this function.
  if (c == '>' || c == 'd')
  {
    return 1;
  }
  else if (c == '<' || c == 'a')
  {
    return -1;
  }
  return 0;
}

static int incr_y(char c)
{
  // TODO: Implement this function.
  if (c == 'v' || c == 's')
  {
    return 1;
  }
  else if (c == '^' || c == 'w')
  {
    return -1;
  }
  return 0;
}

/* Task 4.2 */
static char next_square(game_state_t *state, int snum)
{
  // TODO: Implement this function.
  switch (get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y))
  {
  case '^':
    return get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y - 1);
  case 'w':
    return get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y - 1);
  case '<':
    return get_board_at(state, state->snakes[snum].head_x - 1, state->snakes[snum].head_y);
  case 'a':
    return get_board_at(state, state->snakes[snum].head_x - 1, state->snakes[snum].head_y);
  case 'v':
    return get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y + 1);
  case 's':
    return get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y + 1);
  case '>':
    return get_board_at(state, state->snakes[snum].head_x + 1, state->snakes[snum].head_y);
  case 'd':
    return get_board_at(state, state->snakes[snum].head_x + 1, state->snakes[snum].head_y);
  }
  return '?';
}

/* Task 4.3 */
static void update_head(game_state_t *state, int snum)
{
  switch (get_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y))
  {
  case '^':
    set_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y - 1, '^');
    state->snakes[snum].head_y--;
    return;
  case 'w':
    set_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y - 1, '^');
    state->snakes[snum].head_y--;
    return;
  case '<':
    set_board_at(state, state->snakes[snum].head_x - 1, state->snakes[snum].head_y, '<');
    state->snakes[snum].head_x--;
    return;
  case 'a':
    set_board_at(state, state->snakes[snum].head_x - 1, state->snakes[snum].head_y, '<');
    state->snakes[snum].head_x--;
    return;
  case 'v':
    set_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y + 1, 'v');
    state->snakes[snum].head_y++;
    return;
  case 's':
    set_board_at(state, state->snakes[snum].head_x, state->snakes[snum].head_y + 1, 'v');
    state->snakes[snum].head_y++;
    return;
  case '>':
    set_board_at(state, state->snakes[snum].head_x + 1, state->snakes[snum].head_y, '>');
    state->snakes[snum].head_x++;
    return;
  case 'd':
    set_board_at(state, state->snakes[snum].head_x + 1, state->snakes[snum].head_y, '>');
    state->snakes[snum].head_x++;
    return;
  }
  return;
}
static void update_tail_helper(game_state_t *state, char tail_forward, int x, int y);
/* Task 4.4 */
static void update_tail(game_state_t *state, int snum)
{
  // TODO: Implement this function.
  int x = state->snakes[snum].tail_x;
  int y = state->snakes[snum].tail_y;
  switch (get_board_at(state, x, y))
  {
  case 'w':
    update_tail_helper(state, get_board_at(state, x, y - 1), x, y - 1);
    state->snakes[snum].tail_y--;
    set_board_at(state, x, y, ' ');
    return;
  case 'a':
    update_tail_helper(state, get_board_at(state, x - 1, y), x - 1, y);
    state->snakes[snum].tail_x--;
    set_board_at(state, x, y, ' ');
    return;
  case 's':
    update_tail_helper(state, get_board_at(state, x, y + 1), x, y + 1);
    state->snakes[snum].tail_y++;
    set_board_at(state, x, y, ' ');
    return;
  case 'd':
    update_tail_helper(state, get_board_at(state, x + 1, y), x + 1, y);
    set_board_at(state, x, y, ' ');
    state->snakes[snum].tail_x++;
    return;
  }
  return;
}
static void update_tail_helper(game_state_t *state, char tail_forward, int x, int y)
{
  switch (tail_forward)
  {
  case '^':
    set_board_at(state, x, y, 'w');
    break;
  case '<':
    set_board_at(state, x, y, 'a');
    break;
  case 'v':
    set_board_at(state, x, y, 's');
    break;
  case '>':
    set_board_at(state, x, y, 'd');
    break;
  }
}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state))
{
  // TODO: Implement this function.
  for (int i = 0; i < state->num_snakes; i++)
  {
    if (!state->snakes[i].live)
      continue;
    char next_square_ = next_square(state, i);
    if (next_square_ == ' ' )
    {
      // just move
      update_head(state, i);
      update_tail(state, i);
    }
    else if (next_square_ == '*' )
    {
      // eat a fruit
      update_head(state, i);
      add_food(state);
    }else if(next_square_ == 'x'){
      update_head(state, i);
    }
    else
    {
      // Just dead
      state->snakes[i].live = false;
      set_board_at(state, state->snakes[i].head_x, state->snakes[i].head_y, 'x');
    }
  }
  return;
}

static off_t get_file_size(char *filename){
  struct stat buf;
  stat(filename , &buf);
  return buf.st_size;
}
/* Task 5 */
game_state_t *load_board(char *filename)
{
  // TODO: Implement this function.
  FILE *fp = fopen(filename , "r");
  int width = 0;
  int height = 0;
  int limit = 1024;
  char buf[limit];
  memset(buf,0,limit);
  fgets(buf,limit,fp);
  width = strlen(buf) - 1;
  height = get_file_size(filename) / (width + 1);
  game_state_t *ans = (game_state_t *)malloc(sizeof(game_state_t));
  ans->x_size = width;
  ans->y_size = height;
  ans->board = (char **)malloc(sizeof(char *) * height);
  for (int i = 0; i < height; i++)
  {
    ans->board[i] = (char *)malloc(sizeof(char) * width);
  }
  strncpy(ans->board[0] , buf,width);
  for(int i = 1 ; i < height ; i++){
    memset(buf,0,limit);
    fgets(buf,limit,fp);
    strncpy(ans->board[i] , buf,width);
  }
  return ans;
}

/* Task 6.1 */
static void find_head(game_state_t *state, int snum)
{
  int count = 0;
  int i , j ;
  for(i = 0 ; i < state->x_size ;i++){
    for( j = 0 ; j < state->y_size ;j++){
      if(is_tail(get_board_at(state , i , j ))){
        if(count == snum){
          goto out;
        }
        count++;
      }
    }
  }
out:;
  if(i == state->x_size)return;
  // find the head
  state->snakes[snum].tail_x = i;
  state->snakes[snum].tail_y = j;
  int i_pre;
  int j_pre;
  state->snakes[snum].live = true;
  while(is_snake_init(get_board_at(state,i,j))){
    // 这里假定开始没有dead snake
    char c = get_board_at(state, i , j);
    i_pre = i;
    j_pre = j;
    i += incr_x(c);
    j += incr_y(c);
  }
  state->snakes[snum].head_x = i_pre;
  state->snakes[snum].head_y = j_pre;
  return;
}
static int num_snakes(game_state_t *state){
  int count = 0;
  for(int i = 0 ; i< state->x_size ; i++){
    for(int j = 0 ; j < state->y_size ;j++){
      if(is_tail(get_board_at(state , i , j ))){
        count++;
      }
    }
  }
  return count;
}
/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state)
{
  // TODO: Implement this function.
  state->num_snakes = num_snakes(state);
  state->snakes = (snake_t *)malloc(sizeof(snake_t) * state->num_snakes );
  for(int i = 0 ; i < state->num_snakes ; i++){
    find_head(state,i);
  }
  return state;
}
