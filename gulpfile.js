var gulp = require('gulp'),
    connect = require('gulp-connect'),
    scss = require('gulp-sass'),
    coffee = require('gulp-coffee'),
    spritesmith = require('gulp.spritesmith'),
    buffer = require('vinyl-buffer'),
    merge = require('merge-stream'),
    uglify = require('gulp-uglify'),
    csso = require('gulp-csso'),
    gutil = require('gulp-util');

var HTML_DIR = 'app/views/**/*.html.erb',
    SCSS_DIR = 'app/assets/stylesheets/scss/**/*.scss',
    CSS_DIR = 'app/assets/stylesheets/**/*.css',
    COFFEE_DIR = 'app/assets/coffeescripts/**/*.coffee',
    JS_DIR = 'app/assets/javascripts/**/*.js',
    SPRITES_DIR = 'app/assets/images/sprites/**/*.png';

gulp.task('connect', function() {
  connect.server({
    livereload: true
  });
});

gulp.task('html', function() {
  return gulp.src(HTML_DIR)
    .pipe(connect.reload());
});

gulp.task('scss', function() {
  return gulp.src(SCSS_DIR)
    .pipe(scss().on('error', scss.logError))
    .pipe(gulp.dest('app/assets/stylesheets'));
});

gulp.task('csso', function() {
  return gulp.src(CSS_DIR)
  .pipe(csso())
  .pipe(gulp.dest('app/assets/stylesheets'))
  .pipe(connect.reload());
})

gulp.task('coffee', function() {
  return gulp.src(COFFEE_DIR)
    .pipe(coffee({bare: true})).on('error', gutil.log)
    .pipe(gulp.dest('app/assets/javascripts'));
});

gulp.task('uglify', function() {
  return gulp.src([JS_DIR, '!app/assets/javascripts/application.js'])
    .pipe(uglify())
    .pipe(gulp.dest('app/assets/javascripts'))
    .pipe(connect.reload());
});

gulp.task('spritesmith', function() {
  var data = gulp.src(SPRITES_DIR)
    .pipe(spritesmith({
      imgName: 'sprites.png',
      imgPath: '/images/sprites.png', 
      cssName: '_sprites.scss'
    }));

  var img = data.img
    .pipe(buffer())
    .pipe(gulp.dest('public/images'));

  var css = data.css
    .pipe(buffer())
    .pipe(gulp.dest('app/assets/stylesheets/scss'));

  return merge(img, css);
});

gulp.task('default', ['connect'], function() {
  gulp.watch(HTML_DIR, ['html']);
  gulp.watch(SCSS_DIR, ['scss']);
  gulp.watch(CSS_DIR, ['csso']);
  gulp.watch(COFFEE_DIR, ['coffee']);
  gulp.watch(JS_DIR, ['uglify']);
  gulp.watch(SPRITES_DIR, ['spritesmith']);
});