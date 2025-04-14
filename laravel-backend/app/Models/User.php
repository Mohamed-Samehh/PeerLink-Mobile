<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name', 'username', 'email', 'password', 'phone_num', 'dob', 'gender', 'bio', 'profile_picture'
    ];

    protected $hidden = ['password', 'profile_picture'];

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function followers()
    {
        return $this->hasMany(Follow::class, 'followed_id');
    }

    public function following()
    {
        return $this->hasMany(Follow::class, 'follower_id');
    }

    public function likes()
    {
        return $this->hasMany(Like::class);
    }
}
