<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\FollowController;
use App\Http\Controllers\LikeController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'update']);
    Route::put('/password', [UserController::class, 'updatePassword']);
    Route::get('/posts', [PostController::class, 'index']);
    Route::get('/user-posts', [PostController::class, 'userPosts']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::delete('/posts/{post}', [PostController::class, 'destroy']);
    Route::post('/follow/{user}', [FollowController::class, 'toggle']);
    Route::get('/search', [FollowController::class, 'search']);
    Route::get('/following', [FollowController::class, 'following']);
    Route::get('/followers', [FollowController::class, 'followers']);
    Route::get('/follow-back', [FollowController::class, 'followBack']);
    Route::get('/explore', [FollowController::class, 'explore']);
    Route::post('/like/{post}', [LikeController::class, 'toggle']);
    Route::get('/likes/{post}', [LikeController::class, 'index']);
});
