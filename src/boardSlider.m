%
% [updatedArr, updatedScore] = boardSlider(arr,direction, score)
% ** the function move the values in the array in the specified direction,
% merging like tiles in the same fashion as the original game, 2048 **
%
% arr = an array containing  values of tiles and blanks, where
% a blank space is represented by a 0 and a tile is represented by an
% exponential of 2. 
% direction = string representation of user input from arrow keys - 'left',
% 'right', 'up', or 'down'
% score = the current score of the game
%
% updatedArr = the arr after transition
% updatedScore = the new calculated score, calculated based on the number
% of tiles created