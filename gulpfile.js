var gulp = require('gulp');
    nodemon = require('gulp-nodemon');

gulp.task('default', function(){
    nodemon({
      script: 'app.coffee',
      ext: 'js',
      env: {
        PORT:3000,
        URL:'http://node.locomote.com/code-task'
      },
      ignore: ['./node_modules/**']
    })
    .on('restart', function(){
      console.log('Restarting');
    });
});
